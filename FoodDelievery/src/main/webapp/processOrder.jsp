<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- 1. JAVA BACKGROUND DATABASE PROCESSING ---
    String userEmail = (String) session.getAttribute("userEmail");

    if (userEmail == null || userEmail.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean orderPlaced = false;
    String errorMsg = "";

    // --- 2. HANDLE FORM SUBMISSION ---
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("submitOrder") != null) {
        
        String totalAmount = (String) session.getAttribute("checkoutTotal");
        String quantStr = (String) session.getAttribute("checkoutQuant"); 
        String itemsStr = (String) session.getAttribute("checkoutItems");
        
        // Get Payment Details
        String payOption = request.getParameter("payOption");
        String upiPin = request.getParameter("upiPin");
        String debitPin = request.getParameter("debitPin");
        String creditPin = request.getParameter("creditPin");
        
        // --- SERVER-SIDE VALIDATION (NO JAVASCRIPT) ---
        if (totalAmount == null) {
            errorMsg = "Session expired. Your cart is empty.";
        } 
        else if ("upi".equals(payOption)) {
            if (upiPin == null || !upiPin.matches("\\d{4}")) {
                errorMsg = "Please enter a valid 4-digit UPI PIN.";
            }
        } 
        else if ("debit".equals(payOption)) {
            if (debitPin == null || !debitPin.matches("\\d{6}")) {
                errorMsg = "Please enter a valid 6-digit Debit Card PIN.";
            }
        }
        else if ("credit".equals(payOption)) {
            if (creditPin == null || !creditPin.matches("\\d{6}")) {
                errorMsg = "Please enter a valid 6-digit Credit Card PIN.";
            }
        }

        // Only proceed to Database if there are no validation errors
        if (errorMsg.isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

                // Generate a new ORDER_ID 
                int newOrderId = 1;
                pstmt = conn.prepareStatement("SELECT NVL(MAX(ORDER_ID), 0) + 1 FROM orders");
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    newOrderId = rs.getInt(1);
                }
                pstmt.close(); rs.close();

                // Find Rider
                int assignedRiderId = 0;
                String findRiderSql = "SELECT RIDER_ID FROM (SELECT RIDER_ID FROM riders WHERE CURRENT_STATUS = 'online' AND RIDER_ID != 61 ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1";
                pstmt = conn.prepareStatement(findRiderSql);
                rs = pstmt.executeQuery();
                if(rs.next()){ assignedRiderId = rs.getInt(1); }
                pstmt.close(); rs.close();

                if (assignedRiderId == 0) { assignedRiderId = 61; }

                // Insert the Order
                String sql = "INSERT INTO orders (ORDER_ID, CUSTOMER_EMAIL, RIDER_ID, TOTAL_AMOUNT, ORDER_DATE, QUANT, ORDER_STATUS, PAYOPTION, ITEMS) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, ?, 'Pending Acceptance', ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, newOrderId);
                pstmt.setString(2, userEmail);
                pstmt.setInt(3, assignedRiderId);
                pstmt.setDouble(4, Double.parseDouble(totalAmount));
                pstmt.setString(5, (quantStr.length() > 5) ? quantStr.substring(0, 5) : quantStr);
                pstmt.setString(6, payOption); // Stores 'cod', 'upi', 'debit', or 'credit'
                pstmt.setString(7, itemsStr); 

                int rows = pstmt.executeUpdate();
                
                if(rows > 0) {
                    session.removeAttribute("sessionCart");
                    session.removeAttribute("checkoutTotal");
                    session.removeAttribute("checkoutQuant");
                    session.removeAttribute("checkoutItems");
                    orderPlaced = true; 
                }
                
            } catch (Exception e) {
                errorMsg = "Database Error: " + e.getMessage();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout | FoodieDash</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root { --dark: #2d3436; --light: #f9f9fb; --text-muted: #636e72; --theme: #6c5ce7; --theme-gradient: linear-gradient(to right, #6c5ce7, #fd79a8); --success: #2ecc71; --danger: #ff4757; }
        body { font-family: 'Poppins', sans-serif; margin: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; box-sizing: border-box; background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #fd79a8); background-size: 400% 400%; animation: gradientBG 15s ease infinite; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }
        
        .checkout-card { background: rgba(255, 255, 255, 0.95); padding: 40px; border-radius: 24px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); width: 100%; max-width: 500px; text-align: center; backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.3); }
        .checkout-card h2 { margin-top: 0; color: var(--dark); font-weight: 800; font-size: 1.8rem; }
        
        .error-msg { background: rgba(255, 71, 87, 0.1); color: var(--danger); padding: 10px; border-radius: 10px; margin-bottom: 20px; font-weight: 700; border: 1px solid rgba(255, 71, 87, 0.3); font-size: 0.9rem; }

        .payment-options { text-align: left; margin-bottom: 20px; }
        .payment-wrapper { margin-bottom: 10px; }
        .payment-wrapper input[type="radio"] { display: none; }
        .payment-method { display: block; padding: 15px; border: 2px solid #e2e8f0; border-radius: 12px; cursor: pointer; transition: 0.2s; font-weight: 600; color: var(--dark); background: #fff; position: relative; }
        .payment-method::before { content: ''; display: inline-block; width: 16px; height: 16px; border: 2px solid #cbd5e1; border-radius: 50%; margin-right: 10px; vertical-align: text-top; transition: 0.2s; }
        
        .payment-wrapper input[type="radio"]:checked + .payment-method { border-color: var(--theme); background: rgba(108, 92, 231, 0.05); }
        .payment-wrapper input[type="radio"]:checked + .payment-method::before { border-color: var(--theme); background: var(--theme); box-shadow: inset 0 0 0 3px #fff; }

        .pin-box { display: none; margin-top: 10px; padding: 15px; background: #f9f9fb; border-radius: 10px; animation: slideDown 0.3s ease-out forwards; }
        @keyframes slideDown { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .payment-wrapper input[type="radio"]:checked ~ .pin-box { display: block; }

        .pin-box label { display: block; font-size: 0.85rem; margin-bottom: 8px; color: var(--dark); font-weight: 700; text-transform: uppercase; }
        .pin-box input { width: 100%; padding: 14px; border: 2px solid #f1f2f6; border-radius: 12px; box-sizing: border-box; font-family: 'Poppins', sans-serif; font-size: 1.2rem; text-align: center; letter-spacing: 5px; outline: none; background: #f9f9fb; }
        
        .btn { width: 100%; padding: 16px; border: none; border-radius: 12px; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: transform 0.2s; color: white; display: block; text-decoration: none; box-sizing: border-box; }
        .btn-pay { background: var(--theme-gradient); }
        .btn-pay:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(108, 92, 231, 0.2); }

        #success-screen { display: flex; flex-direction: column; align-items: center; justify-content: center; }
        .success-icon { width: 80px; height: 80px; background: var(--success); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2.5rem; margin-bottom: 20px; }
        .success-text { color: var(--success); font-weight: 800; font-size: 1.5rem; margin: 0 0 10px 0; }
    </style>
</head>
<body>

    <div class="checkout-card">
        
        <% if (orderPlaced) { %>
            <div id="success-screen">
                <div class="success-icon"><i class="fas fa-check"></i></div>
                <h3 class="success-text">Order Placed!</h3>
                <p>Your order is on its way.</p>
                <a href="track.jsp" class="btn btn-pay" style="margin-top:20px;">Track Order</a>
            </div>

        <% } else { %>
            <div id="payment-form">
                <h2>Payment Method</h2>
                <p style="color: var(--text-muted); margin-bottom: 25px;">Choose your preferred payment method</p>
                
                <% if (!errorMsg.isEmpty()) { %>
                    <div class="error-msg"><i class="fas fa-exclamation-circle"></i> <%= errorMsg %></div>
                <% } %>

                <form method="POST" action="processOrder.jsp">
                    <input type="hidden" name="submitOrder" value="true">
                    
                    <div class="payment-options">
                        
                        <div class="payment-wrapper">
                            <input type="radio" name="payOption" id="pay-cod" value="cod" checked>
                            <label for="pay-cod" class="payment-method">Cash on Delivery (COD)</label>
                        </div>

                        <div class="payment-wrapper">
                            <input type="radio" name="payOption" id="pay-upi" value="upi">
                            <label for="pay-upi" class="payment-method">UPI Payment</label>
                            <div class="pin-box">
                                <label>Enter 4-Digit UPI PIN</label>
                                <input type="password" name="upiPin" maxlength="4" pattern="\d{4}" inputmode="numeric" placeholder="••••">
                            </div>
                        </div>

                        <div class="payment-wrapper">
                            <input type="radio" name="payOption" id="pay-debit" value="debit">
                            <label for="pay-debit" class="payment-method">Debit Card</label>
                            <div class="pin-box">
                                <label>Enter 6-Digit Debit PIN</label>
                                <input type="password" name="debitPin" maxlength="6" pattern="\d{6}" inputmode="numeric" placeholder="••••••">
                            </div>
                        </div>

                        <div class="payment-wrapper">
                            <input type="radio" name="payOption" id="pay-credit" value="credit">
                            <label for="pay-credit" class="payment-method">Credit Card</label>
                            <div class="pin-box">
                                <label>Enter 6-Digit Secure PIN</label>
                                <input type="password" name="creditPin" maxlength="6" pattern="\d{6}" inputmode="numeric" placeholder="••••••">
                            </div>
                        </div>

                    </div>
                    <button type="submit" class="btn btn-pay">Confirm & Pay</button>
                </form>
            </div>
        <% } %>

    </div>

</body>
</html>