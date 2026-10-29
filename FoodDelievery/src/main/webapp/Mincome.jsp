<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monthly Income | FoodieDash</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
    
    <style>
        :root { --dark: #2d3436; --light: #f4f6f8; --white: #ffffff; --text-muted: #636e72; --theme: #6c5ce7; --theme-accent: #a29bfe; --success: #00b894; --warning: #f39c12; }
        body { font-family: 'Poppins', sans-serif; margin: 0; background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #f39c12); background-size: 400% 400%; animation: gradientBG 15s ease infinite; min-height: 100vh; padding: 20px; display: flex; flex-direction: column; align-items: center; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }

        .header { width: 100%; max-width: 600px; display: flex; align-items: center; margin-bottom: 20px; }
        .back-btn { color: white; font-size: 1.5rem; text-decoration: none; transition: 0.2s; margin-right: 15px; }
        .back-btn:hover { transform: translateX(-5px); }
        h1 { color: white; margin: 0; font-weight: 800; font-size: 1.6rem; }

        .income-card { background: rgba(255, 255, 255, 0.95); padding: 30px; border-radius: 24px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); width: 100%; max-width: 600px; backdrop-filter: blur(10px); text-align: center; margin-bottom: 20px; }
        .income-title { color: var(--text-muted); font-weight: 600; text-transform: uppercase; letter-spacing: 1px; font-size: 0.9rem; margin-bottom: 10px; }
        .income-amount { color: var(--success); font-size: 3.5rem; font-weight: 800; margin: 0; text-shadow: 0 4px 10px rgba(0, 184, 148, 0.2); }
        .total-deliveries { display: inline-block; background: #e2e8f0; color: var(--dark); padding: 5px 15px; border-radius: 20px; font-weight: 700; font-size: 0.9rem; margin-top: 15px; }

        .history-list { width: 100%; max-width: 600px; }
        .history-item { background: var(--white); padding: 20px; border-radius: 16px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 5px 15px rgba(0,0,0,0.05); border-left: 4px solid var(--warning); }
        .item-left h4 { margin: 0 0 5px 0; color: var(--dark); font-size: 1.1rem; }
        .item-left p { margin: 0; color: var(--text-muted); font-size: 0.85rem; }
        .item-right { text-align: right; }
        .item-right h4 { margin: 0 0 5px 0; color: var(--success); font-size: 1.2rem; }
        .item-right p { margin: 0; color: var(--text-muted); font-size: 0.85rem; }

        .empty-state { text-align: center; color: var(--white); padding: 40px 20px; }
        .empty-state i { font-size: 4rem; opacity: 0.5; margin-bottom: 15px; }
    </style>
</head>
<body>

    <div class="header">
        <a href="RiderDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
        <h1><i class="fas fa-chart-line"></i> Monthly Income</h1>
    </div>

    <%
        String riderName = (String) session.getAttribute("riderName");
        if (riderName == null || riderName.trim().isEmpty()) {
            response.sendRedirect("login1.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        double totalEarnedMonth = 0.0;
        int deliveriesMonth = 0;
        String currentMonthName = new SimpleDateFormat("MMMM yyyy").format(new java.util.Date());

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

            // 1. Get Rider ID
            int riderId = -1;
            pstmt = conn.prepareStatement("SELECT RIDER_ID FROM riders WHERE RIDER_NAME = ?");
            pstmt.setString(1, riderName);
            rs = pstmt.executeQuery();
            if(rs.next()) riderId = rs.getInt("RIDER_ID");
            pstmt.close(); rs.close();

            // 2. Fetch THIS MONTH'S completed orders using Oracle's TO_CHAR matcher
            String sql = "SELECT ORDER_ID, TOTAL_AMOUNT, ORDER_DATE FROM orders WHERE RIDER_ID = ? AND ORDER_STATUS IN ('Delivered', 'Final Delivered') AND TO_CHAR(ORDER_DATE, 'YYYY-MM') = TO_CHAR(SYSDATE, 'YYYY-MM') ORDER BY ORDER_DATE DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, riderId);
            rs = pstmt.executeQuery();
            
            StringBuilder historyHtml = new StringBuilder();
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM, hh:mm a");

            while(rs.next()) {
                deliveriesMonth++;
                int orderId = rs.getInt("ORDER_ID");
                double orderTotal = rs.getDouble("TOTAL_AMOUNT");
                double earned = orderTotal * 0.05; // 5% Commission
                totalEarnedMonth += earned;
                
                Timestamp orderDate = rs.getTimestamp("ORDER_DATE");
                String dateStr = (orderDate != null) ? dateFormat.format(orderDate) : "Unknown Date";

                historyHtml.append("<div class='history-item'>")
                           .append("<div class='item-left'>")
                           .append("<h4>Order #").append(orderId).append("</h4>")
                           .append("<p><i class='far fa-calendar-alt'></i> ").append(dateStr).append("</p>")
                           .append("</div>")
                           .append("<div class='item-right'>")
                           .append("<h4>+₹").append(String.format("%.2f", earned)).append("</h4>")
                           .append("<p>Order Val: ₹").append(orderTotal).append("</p>")
                           .append("</div>")
                           .append("</div>");
            }
    %>

    <div class="income-card">
        <div class="income-title">Earnings For <%= currentMonthName %></div>
        <h2 class="income-amount">₹<%= String.format("%.2f", totalEarnedMonth) %></h2>
        <div class="total-deliveries"><i class="fas fa-route"></i> <%= deliveriesMonth %> Deliveries This Month</div>
    </div>

    <div class="history-list">
        <% if (deliveriesMonth > 0) { %>
            <%= historyHtml.toString() %>
        <% } else { %>
            <div class="empty-state">
                <i class="fas fa-sad-tear"></i>
                <h3>No deliveries this month</h3>
                <p>Time to hit the road and start earning!</p>
            </div>
        <% } %>
    </div>

    <%
        } catch (Exception e) {
            out.println("<p style='color:red; text-align:center; background:white; padding:20px; border-radius:10px;'>Database Error: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    %>

</body>
</html>