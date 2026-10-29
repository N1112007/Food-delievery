<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Coupons | Hotel Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
    
    <style>
        :root { --dark: #2d3436; --theme: #6c5ce7; --theme-accent: #a29bfe; --success: #00b894; --danger: #ff7675; --light: #f8fafc; --warning: #f1c40f; }
        body { font-family: 'Poppins', sans-serif; margin: 0; background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #f1c40f); background-size: 400% 400%; animation: gradientBG 15s ease infinite; min-height: 100vh; padding: 40px 20px; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }

        .container { width: 100%; max-width: 800px; }
        
        .top-bar { display: flex; justify-content: flex-start; margin-bottom: 20px; }
        .back-link { text-decoration: none; color: white; background: rgba(255, 255, 255, 0.2); padding: 10px 20px; border-radius: 12px; font-weight: 700; transition: 0.2s; display: flex; align-items: center; gap: 8px; backdrop-filter: blur(5px); border: 1px solid rgba(255,255,255,0.3); }
        .back-link:hover { background: white; color: var(--theme); }

        /* --- ADD COUPON CARD --- */
        .add-card { background: rgba(255, 255, 255, 0.95); padding: 30px; border-radius: 24px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.3); margin-bottom: 30px; }
        .add-card h2 { margin: 0 0 5px 0; color: var(--dark); font-weight: 800; font-size: 1.5rem; display: flex; align-items: center; gap: 10px; }
        .add-card p { margin: 0 0 20px 0; color: #636e72; font-size: 0.9rem; }

        .form-row { display: flex; gap: 15px; margin-bottom: 15px; flex-wrap: wrap; }
        .input-group { flex: 1; min-width: 200px; }
        label { display: block; font-size: 0.8rem; color: var(--dark); margin-bottom: 6px; font-weight: 700; text-transform: uppercase; }
        
        input[type="text"], input[type="number"] { width: 100%; padding: 14px; border: 2px solid #e2e8f0; border-radius: 12px; font-family: 'Poppins', sans-serif; font-size: 1rem; transition: 0.3s; background: var(--light); box-sizing: border-box; }
        input:focus { outline: none; border-color: var(--theme); background: white; box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.1); }
        input[name="code"] { text-transform: uppercase; font-weight: 800; color: var(--theme); letter-spacing: 1px; }

        .btn-add { width: 100%; padding: 16px; background: linear-gradient(to right, var(--theme), #a29bfe); color: white; border: none; border-radius: 12px; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: 0.2s; margin-top: 10px; }
        .btn-add:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(108, 92, 231, 0.3); }

        /* --- ACTIVE COUPONS GRID --- */
        .coupons-header { color: white; margin: 0 0 15px 10px; font-weight: 800; text-shadow: 0 2px 5px rgba(0,0,0,0.3); }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        
        /* Ticket Style Design */
        .coupon-item { background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 20px rgba(0,0,0,0.15); display: flex; position: relative; transition: 0.3s; border: 2px dashed #cbd5e1; }
        .coupon-item:hover { transform: translateY(-5px); border-color: var(--warning); box-shadow: 0 15px 25px rgba(241, 196, 15, 0.3); }
        
        .coupon-left { background: var(--warning); color: var(--dark); padding: 20px 15px; display: flex; flex-direction: column; justify-content: center; align-items: center; width: 80px; text-align: center; border-right: 2px dashed rgba(0,0,0,0.1); }
        .coupon-left span { font-size: 1.8rem; font-weight: 800; line-height: 1; }
        .coupon-left small { font-size: 0.7rem; font-weight: 700; text-transform: uppercase; margin-top: 5px; }

        .coupon-right { padding: 20px; flex: 1; display: flex; flex-direction: column; justify-content: center; overflow: hidden; }
        .coupon-code { font-size: 1.2rem; font-weight: 800; color: var(--theme); margin: 0 0 5px 0; letter-spacing: 1px; }
        
        /* Fixed: Added wrapping for long descriptions */
        .coupon-desc { font-size: 0.85rem; color: #636e72; margin: 0 0 10px 0; line-height: 1.4; word-wrap: break-word; overflow-wrap: anywhere; }
        
        .coupon-min { font-size: 0.8rem; font-weight: 700; color: var(--success); background: rgba(0, 184, 148, 0.1); padding: 4px 8px; border-radius: 6px; display: inline-block; align-self: flex-start; }

        .btn-remove { position: absolute; top: 15px; right: 15px; background: rgba(255, 118, 117, 0.1); color: var(--danger); border: none; width: 35px; height: 35px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center; }
        .btn-remove:hover { background: var(--danger); color: white; }

        .message { padding: 12px 20px; border-radius: 12px; margin-bottom: 20px; font-weight: 700; text-align: center; }
        .msg-success { background: rgba(0, 184, 148, 0.9); color: white; backdrop-filter: blur(5px); }
        .msg-error { background: rgba(255, 118, 117, 0.9); color: white; backdrop-filter: blur(5px); }
    </style>
</head>
<body>

    <div class="container">
        <div class="top-bar">
            <a href="HotelDashbord.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Dashboard</a>
        </div>

        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            String message = "";
            String msgType = "";

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String action = request.getParameter("action");

                    if ("add".equals(action)) {
                        String code = request.getParameter("code").toUpperCase().trim();
                        String discount = request.getParameter("discount");
                        String minOrder = request.getParameter("minOrder");
                        String desc = request.getParameter("description");

                        if (code != null && !code.isEmpty()) {
                            try {
                                int nextId = 1;
                                pstmt = conn.prepareStatement("SELECT NVL(MAX(COUPON_ID), 0) + 1 FROM COUPONS");
                                rs = pstmt.executeQuery();
                                if(rs.next()) nextId = rs.getInt(1);
                                rs.close(); pstmt.close();

                                pstmt = conn.prepareStatement("INSERT INTO COUPONS (COUPON_ID, CODE, DISCOUNT_AMOUNT, MIN_ORDER, DESCRIPTION) VALUES (?, ?, ?, ?, ?)");
                                pstmt.setInt(1, nextId);
                                pstmt.setString(2, code);
                                pstmt.setDouble(3, Double.parseDouble(discount));
                                pstmt.setDouble(4, Double.parseDouble(minOrder));
                                pstmt.setString(5, desc);
                                pstmt.executeUpdate();
                                pstmt.close();

                                message = "Promo Code '" + code + "' activated successfully!";
                                msgType = "msg-success";
                            } catch (SQLIntegrityConstraintViolationException e) {
                                message = "This promo code already exists! Try a different code.";
                                msgType = "msg-error";
                            }
                        }
                    }
                    else if ("remove".equals(action)) {
                        String removeId = request.getParameter("couponId");
                        if (removeId != null) {
                            pstmt = conn.prepareStatement("DELETE FROM COUPONS WHERE COUPON_ID = ?");
                            pstmt.setInt(1, Integer.parseInt(removeId));
                            pstmt.executeUpdate();
                            pstmt.close();

                            message = "Coupon deactivated successfully.";
                            msgType = "msg-success";
                        }
                    }
                }
        %>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= msgType %>"><%= message %></div>
        <% } %>

        <div class="add-card">
            <h2><i class="fas fa-ticket-alt" style="color: var(--warning);"></i> Create Promo Code</h2>
            <p>Offer discounts to your customers to increase cart value.</p>
            
            <form method="POST">
                <input type="hidden" name="action" value="add">
                
                <div class="form-row">
                    <div class="input-group">
                        <label>Promo Code (e.g., SAVE50)</label>
                        <input type="text" name="code" required maxlength="20" placeholder="SUMMER25">
                    </div>
                    <div class="input-group">
                        <label>Discount Amount (₹)</label>
                        <input type="number" name="discount" required min="1" placeholder="50">
                    </div>
                    <div class="input-group">
                        <label>Minimum Order Value (₹)</label>
                        <input type="number" name="minOrder" required min="0" placeholder="200">
                    </div>
                </div>
                
                <div class="input-group" style="margin-bottom: 0;">
                    <label>Description</label>
                    <input type="text" name="description" required maxlength="200" placeholder="Describe the offer (e.g., Valid on all orders above ₹200)">
                </div>

                <button type="submit" class="btn-add"><i class="fas fa-check-circle"></i> Activate Coupon</button>
            </form>
        </div>

        <h3 class="coupons-header"><i class="fas fa-tags"></i> Active Coupons</h3>
        
        <div class="grid">
            <%
                String fetchSql = "SELECT * FROM COUPONS ORDER BY COUPON_ID DESC";
                pstmt = conn.prepareStatement(fetchSql);
                rs = pstmt.executeQuery();
                boolean hasCoupons = false;

                while(rs.next()) {
                    hasCoupons = true;
                    int id = rs.getInt("COUPON_ID");
                    String code = rs.getString("CODE");
                    int discount = rs.getInt("DISCOUNT_AMOUNT");
                    int minOrder = rs.getInt("MIN_ORDER");
                    String desc = rs.getString("DESCRIPTION");
            %>
            
            <div class="coupon-item">
                <div class="coupon-left">
                    <span>₹<%= discount %></span>
                    <small>OFF</small>
                </div>
                <div class="coupon-right">
                    <h4 class="coupon-code"><%= code %></h4>
                    <p class="coupon-desc"><%= desc %></p>
                    <div class="coupon-min">Min Order: ₹<%= minOrder %></div>
                    
                    <form method="POST" style="margin: 0;" onsubmit="return confirm('Are you sure you want to delete this coupon?');">
                        <input type="hidden" name="action" value="remove">
                        <input type="hidden" name="couponId" value="<%= id %>">
                        <button type="submit" class="btn-remove" title="Delete Coupon"><i class="fas fa-trash-alt"></i></button>
                    </form>
                </div>
            </div>

            <%  } 
                if (!hasCoupons) { 
            %>
                <div style="grid-column: 1 / -1; background: rgba(255,255,255,0.9); padding: 30px; border-radius: 16px; text-align: center;">
                    <i class="fas fa-ticket-alt" style="font-size: 3rem; color: #cbd5e1; margin-bottom: 10px;"></i>
                    <p style="margin: 0; font-weight: 600; color: #636e72;">No active coupons yet.</p>
                </div>
            <%  } %>
        </div>

        <%
            } catch (Exception e) {
                out.println("<div class='message msg-error'>Database Error: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </div>
</body>
</html>