<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Session Check
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null || userEmail.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Check if the user clicked the initial "Cancel Order" button
    String cancelIntentId = request.getParameter("cancelIntentId");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Tracking | FoodieDash</title>
    
    <%-- Only auto-refresh if the user is NOT currently deciding whether to cancel --%>
    <% if (cancelIntentId == null) { %>
        <meta http-equiv="refresh" content="5">
    <% } %>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root { --dark: #2d3436; --light: #f9f9fb; --theme: #6c5ce7; --theme-accent: #a29bfe; --success: #00b894; --danger: #ff7675; }
        body { font-family: 'Poppins', sans-serif; margin: 0; min-height: 100vh; background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #00b894); background-size: 400% 400%; animation: gradientBG 15s ease infinite; padding: 20px; display: flex; flex-direction: column; align-items: center; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }

        .header { width: 100%; max-width: 600px; display: flex; align-items: center; margin-bottom: 20px; }
        .back-btn { color: white; font-size: 1.5rem; text-decoration: none; transition: 0.2s; margin-right: 15px; }
        .back-btn:hover { transform: scale(1.1); }
        h1 { color: white; margin: 0; font-weight: 800; font-size: 1.6rem; }

        .tracker-card { background: rgba(255, 255, 255, 0.95); padding: 40px 30px; border-radius: 24px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); width: 100%; max-width: 600px; backdrop-filter: blur(10px); box-sizing: border-box; text-align: center; margin-bottom: 30px; }
        .order-id { font-size: 1.2rem; font-weight: 800; color: var(--dark); margin-bottom: 5px; }
        .status-text { font-size: 1rem; color: var(--theme); font-weight: 700; margin-bottom: 40px; text-transform: uppercase; letter-spacing: 1px; }

        /* --- PROGRESS BAR ANIMATIONS --- */
        .progress-container { display: flex; justify-content: space-between; position: relative; margin-bottom: 40px; }
        .progress-container::before { content: ''; position: absolute; top: 50%; left: 0; transform: translateY(-50%); height: 4px; width: 100%; background: #dfe6e9; z-index: 1; }
        
        .progress-line { position: absolute; top: 50%; left: 0; transform: translateY(-50%); height: 4px; background: var(--success); z-index: 2; transition: width 0.5s ease; }
        
        .step { position: relative; z-index: 3; width: 40px; height: 40px; background: #dfe6e9; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; color: #b2bec3; transition: 0.4s; }
        .step.active { background: var(--theme); color: white; box-shadow: 0 0 0 5px rgba(108, 92, 231, 0.2); animation: pulseStep 2s infinite; }
        .step.completed { background: var(--success); color: white; }
        
        @keyframes pulseStep { 0% { box-shadow: 0 0 0 0 rgba(108, 92, 231, 0.5); } 70% { box-shadow: 0 0 0 15px rgba(108, 92, 231, 0); } 100% { box-shadow: 0 0 0 0 rgba(108, 92, 231, 0); } }

        .step-label { position: absolute; top: 50px; font-size: 0.75rem; font-weight: 700; color: var(--dark); white-space: nowrap; width: 100px; left: 50%; transform: translateX(-50%); }

        /* --- RIDER CARD --- */
        .rider-card { background: #f8fafc; border: 2px solid #e2e8f0; border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 15px; margin-top: 20px; text-align: left; }
        .rider-avatar { width: 60px; height: 60px; background: var(--theme-accent); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        .rider-info h3 { margin: 0 0 5px 0; color: var(--dark); font-size: 1.1rem; font-weight: 800; }
        .rider-info p { margin: 0; color: var(--text-muted); font-size: 0.9rem; font-weight: 600; }
        .call-btn { margin-left: auto; background: var(--success); color: white; width: 45px; height: 45px; border-radius: 50%; display: flex; align-items: center; justify-content: center; text-decoration: none; font-size: 1.2rem; transition: 0.2s; box-shadow: 0 4px 10px rgba(0, 184, 148, 0.3); }
        .call-btn:hover { transform: scale(1.1); }

        /* --- ACTION BUTTONS --- */
        .confirmation-box { margin-top: 30px; padding-top: 25px; border-top: 2px dashed #e2e8f0; }
        .confirmation-box h3 { margin: 0 0 15px 0; color: var(--dark); font-weight: 800; font-size: 1.1rem; }
        .btn-group { display: flex; gap: 15px; }
        .btn { flex: 1; padding: 14px; border: none; border-radius: 12px; font-size: 1rem; font-weight: 700; cursor: pointer; transition: 0.2s; color: white; }
        .btn-yes { background: var(--success); box-shadow: 0 4px 10px rgba(0, 184, 148, 0.3); }
        .btn-no { background: var(--danger); box-shadow: 0 4px 10px rgba(255, 118, 117, 0.3); }
        .btn-neutral { background: #b2bec3; box-shadow: 0 4px 10px rgba(178, 190, 195, 0.3); color: white; }
        .btn:hover { transform: translateY(-2px); }

        .btn-cancel-order { background: transparent; color: var(--danger); border: 2px solid var(--danger); padding: 12px; border-radius: 12px; font-size: 1rem; font-weight: 700; cursor: pointer; transition: 0.2s; width: 100%; margin-top: 20px; font-family: 'Poppins', sans-serif;}
        .btn-cancel-order:hover { background: rgba(255, 118, 117, 0.1); }

        /* Final Screens */
        .final-screen { text-align: center; padding: 20px; }
        .final-screen i { font-size: 4rem; margin-bottom: 15px; color: #dfe6e9; }
        .final-screen h2 { margin: 0; font-weight: 800; color: var(--dark); }
        .final-screen p { color: var(--text-muted); margin-top: 10px; }
    </style>
</head>
<body>

    <div class="header">
        <a href="CoustmerDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
        <h1>Live Order Tracking</h1>
    </div>

    <div style="width: 100%; display: flex; flex-direction: column; align-items: center;">

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean hasActiveOrders = false;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

            // ==========================================
            // 2. HANDLE POST REQUESTS (Database Updates)
            // ==========================================
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("customerAction");
                String updateOrderId = request.getParameter("orderId");
                
                // We only update the DB if a specific action was passed (yes, no, or cancel)
                // If it's just a 'cancelIntentId' form submission, this block is skipped.
                if (action != null && updateOrderId != null) {
                    String newStatus = "";
                    
                    if (action.equals("yes")) newStatus = "Final Delivered";
                    else if (action.equals("no")) newStatus = "Not Delivered";
                    else if (action.equals("cancel")) newStatus = "Cancelled"; 

                    if (!newStatus.isEmpty()) {
                        String updateSql = "UPDATE orders SET ORDER_STATUS = ? WHERE ORDER_ID = ?";
                        pstmt = conn.prepareStatement(updateSql);
                        pstmt.setString(1, newStatus);
                        pstmt.setInt(2, Integer.parseInt(updateOrderId));
                        pstmt.executeUpdate();
                        pstmt.close();
                    }
                }
            }

            // ==========================================
            // 3. FETCH ACTIVE ORDERS (Excluding 'Cancelled')
            // ==========================================
            String fetchSql = "SELECT o.ORDER_ID, o.ORDER_STATUS, r.RIDER_NAME, r.PHONE_NO " +
                              "FROM orders o LEFT JOIN riders r ON o.RIDER_ID = r.RIDER_ID " +
                              "WHERE o.CUSTOMER_EMAIL = ? AND o.ORDER_STATUS NOT IN ('Final Delivered', 'Not Delivered', 'Cancelled') " +
                              "ORDER BY o.ORDER_DATE DESC";
            
            pstmt = conn.prepareStatement(fetchSql);
            pstmt.setString(1, userEmail);
            rs = pstmt.executeQuery();
            
            // LOOP THROUGH EVERY ACTIVE ORDER
            while(rs.next()) {
                hasActiveOrders = true;
                
                int orderId = rs.getInt("ORDER_ID");
                String status = rs.getString("ORDER_STATUS");
                String riderName = rs.getString("RIDER_NAME");
                String riderPhone = rs.getString("PHONE_NO");

                int step = 0;
                if (status.equalsIgnoreCase("Pending Acceptance") || status.equalsIgnoreCase("Waiting for Rider")) step = 1;
                else if (status.equalsIgnoreCase("Being Prepared")) step = 2;
                else if (status.equalsIgnoreCase("Dispatched") || status.equalsIgnoreCase("Ready for Dispatch")) step = 3;
                else if (status.equalsIgnoreCase("Delivered")) step = 4;
                
                int progressWidth = 0;
                if(step == 1) progressWidth = 0;
                else if(step == 2) progressWidth = 33;
                else if(step == 3) progressWidth = 66;
                else if(step >= 4) progressWidth = 100;
    %>
        <div class="tracker-card">
            <div class="order-id">Order #<%= orderId %></div>
            <div class="status-text"><%= status %>...</div>

            <div class="progress-container">
                <div class="progress-line" style="width: <%= progressWidth %>%;"></div>
                
                <div class="step <%= step >= 1 ? (step == 1 ? "active" : "completed") : "" %>">
                    <i class="fas fa-clock"></i>
                    <span class="step-label">Pending</span>
                </div>
                
                <div class="step <%= step >= 2 ? (step == 2 ? "active" : "completed") : "" %>">
                    <i class="fas fa-fire-burner"></i>
                    <span class="step-label">Preparing</span>
                </div>
                
                <div class="step <%= step >= 3 ? (step == 3 ? "active" : "completed") : "" %>">
                    <i class="fas fa-motorcycle"></i>
                    <span class="step-label">Dispatched</span>
                </div>
                
                <div class="step <%= step >= 4 ? (step == 4 ? "active" : "completed") : "" %>">
                    <i class="fas fa-box-open"></i>
                    <span class="step-label">Delivered</span>
                </div>
            </div>

            <% if (riderName != null) { %>
                <div class="rider-card">
                    <div class="rider-avatar"><i class="fas fa-user-ninja"></i></div>
                    <div class="rider-info">
                        <h3><%= riderName %></h3>
                        <p>Your Delivery Partner</p>
                    </div>
                    <% if (riderPhone != null) { %>
                        <a href="tel:<%= riderPhone %>" class="call-btn"><i class="fas fa-phone-alt"></i></a>
                    <% } %>
                </div>
            <% } else { %>
                <div class="rider-card" style="justify-content: center; color: var(--text-muted);">
                    <p><i class="fas fa-spinner fa-spin"></i> Finding a rider nearby...</p>
                </div>
            <% } %>

            <% if (step <= 2) { %>
                
                <% 
                   // If the user clicked "Cancel Order" for THIS specific order, show the Yes/No buttons
                   if (cancelIntentId != null && cancelIntentId.equals(String.valueOf(orderId))) { 
                %>
                    <div class="confirmation-box">
                        <h3 style="color: var(--danger);">Are you sure you want to cancel?</h3>
                        <div class="btn-group">
                            <form method="POST" action="track.jsp" style="flex: 1;">
                                <input type="hidden" name="orderId" value="<%= orderId %>">
                                <input type="hidden" name="customerAction" value="cancel">
                                <button type="submit" class="btn btn-no"><i class="fas fa-check"></i> Yes, Cancel</button>
                            </form>
                            
                            <form method="GET" action="track.jsp" style="flex: 1;">
                                <button type="submit" class="btn btn-neutral"><i class="fas fa-times"></i> No, Keep it</button>
                            </form>
                        </div>
                    </div>
                <% } else { %>
                    <form method="POST" action="track.jsp">
                        <input type="hidden" name="cancelIntentId" value="<%= orderId %>">
                        <button type="submit" class="btn-cancel-order"><i class="fas fa-ban"></i> Cancel Order</button>
                    </form>
                <% } %>

            <% } %>

            <% if (step == 4) { %>
                <div class="confirmation-box">
                    <h3>Did you receive your order?</h3>
                    <div class="btn-group">
                        <form method="POST" action="track.jsp" style="flex: 1;">
                            <input type="hidden" name="orderId" value="<%= orderId %>">
                            <input type="hidden" name="customerAction" value="yes">
                            <button type="submit" class="btn btn-yes"><i class="fas fa-check"></i> Yes, got it!</button>
                        </form>
                        
                        <form method="POST" action="track.jsp" style="flex: 1;">
                            <input type="hidden" name="orderId" value="<%= orderId %>">
                            <input type="hidden" name="customerAction" value="no">
                            <button type="submit" class="btn btn-no"><i class="fas fa-times"></i> Not yet</button>
                        </form>
                    </div>
                </div>
            <% } %>
        </div>
    <%
            } // END OF THE WHILE LOOP
            
            if (!hasActiveOrders) {
    %>
            <div class="tracker-card">
                <div class="final-screen">
                    <i class="fas fa-shopping-bag"></i>
                    <h2>No Active Orders</h2>
                    <p>You don't have any orders currently out for delivery.</p>
                    <a href="menu.jsp" class="btn btn-yes" style="display:inline-block; text-decoration:none; margin-top:20px;">Order Something Delicious!</a>
                </div>
            </div>
    <%
            }

        } catch (Exception e) {
            out.println("<div class='tracker-card' style='color:red;'>Database Error: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    %>
    </div>

</body>
</html>