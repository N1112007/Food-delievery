<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Income & Transactions | Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        /* --- CORE STYLES --- */
        :root {
            --dark: #2d3436; --light: #f9f9fb; --white: #ffffff; --text-muted: #636e72;
            --theme: #0984e3; --theme-accent: #74b9ff; --success: #00b894; --danger: #ff7675; --warning: #fdcb6e; --purple: #6c5ce7;
            --gold: #f1c40f; /* Added for stars */
        }
        body { font-family: 'Poppins', sans-serif; margin: 0; background-color: var(--light); padding-bottom: 50px; }

        /* --- HEADER --- */
        .admin-header { background: var(--dark); padding: 20px; color: var(--white); display: flex; align-items: center; gap: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); position: sticky; top: 0; z-index: 100; }
        .back-btn { color: var(--white); font-size: 1.5rem; text-decoration: none; transition: 0.2s; }
        .back-btn:hover { color: var(--theme-accent); transform: translateX(-3px); }
        .header-title { margin: 0; font-size: 1.5rem; font-weight: 800; }

        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }

        /* --- SUMMARY CARDS (NOW CLICKABLE FILTERS) --- */
        .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .summary-card { 
            background: var(--white); padding: 25px; border-radius: 16px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); 
            display: flex; align-items: center; gap: 15px; border-left: 5px solid var(--theme); 
            text-decoration: none; color: inherit; cursor: pointer; transition: all 0.3s ease; position: relative;
        }
        .summary-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        
        /* Active Filter Highlight */
        .summary-card.active-filter { border-left-width: 8px; background-color: #fdfdfd; }
        .summary-card.active-filter::after {
            content: '\f0d7'; font-family: 'Font Awesome 5 Free'; font-weight: 900;
            position: absolute; bottom: -18px; left: 50%; transform: translateX(-50%);
            color: var(--dark); font-size: 1.5rem;
        }

        .summary-icon { min-width: 55px; height: 55px; border-radius: 50%; background: rgba(9, 132, 227, 0.1); color: var(--theme); display: flex; align-items: center; justify-content: center; font-size: 1.6rem; }
        
        .summary-card.revenue { border-left-color: var(--success); }
        .summary-card.revenue .summary-icon { background: rgba(0, 184, 148, 0.1); color: var(--success); }
        .summary-card.revenue.active-filter::after { color: var(--success); }

        .summary-card.month { border-left-color: var(--warning); }
        .summary-card.month .summary-icon { background: rgba(253, 203, 110, 0.1); color: #e1b12c; }
        .summary-card.month.active-filter::after { color: var(--warning); }

        .summary-card.all-time { border-left-color: var(--purple); }
        .summary-card.all-time .summary-icon { background: rgba(108, 92, 231, 0.1); color: var(--purple); }
        .summary-card.all-time.active-filter::after { color: var(--purple); }
        
        .summary-info h3 { margin: 0; font-size: 1.8rem; color: var(--dark); font-weight: 800; line-height: 1.2; }
        .summary-info p { margin: 0; color: var(--text-muted); font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; }

        /* --- SEARCH BAR & HEADER --- */
        .list-header { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; margin-bottom: 15px; flex-wrap: wrap; gap: 15px; }
        .section-title { color: var(--dark); font-size: 1.3rem; margin: 0; font-weight: 700; }
        .search-form { display: flex; gap: 10px; }
        .search-input { padding: 10px 15px; border: 1px solid #dfe6e9; border-radius: 8px; font-family: 'Poppins', sans-serif; width: 250px; outline: none; transition: 0.2s; }
        .search-input:focus { border-color: var(--theme); box-shadow: 0 0 0 3px rgba(9, 132, 227, 0.1); }
        .search-btn { background: var(--theme); color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; }
        .search-btn:hover { background: #076aba; }
        .clear-btn { background: #dfe6e9; color: var(--dark); text-decoration: none; padding: 10px 15px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; }

        /* --- ORDER LIST --- */
        .order-card { background: var(--white); border-radius: 16px; padding: 20px; margin-bottom: 15px; box-shadow: 0 4px 10px rgba(0,0,0,0.03); border: 1px solid #edf2f7; display: flex; flex-wrap: wrap; gap: 15px; align-items: center; justify-content: space-between; transition: 0.2s; }
        .order-card:hover { box-shadow: 0 8px 20px rgba(0,0,0,0.08); transform: translateY(-2px); }
        
        .order-main { flex: 1; min-width: 250px; }
        .order-id { font-size: 1.1rem; font-weight: 800; color: var(--dark); margin: 0 0 5px 0; }
        .order-date-time { color: var(--text-muted); font-size: 0.85rem; font-weight: 600; margin-left: 10px; }
        .order-items { margin: 0 0 8px 0; color: var(--text-muted); font-size: 0.95rem; }
        .order-customer { margin: 0; font-size: 0.85rem; color: var(--theme); font-weight: 600; }

        /* --- RATING CSS --- */
        .item-rating { margin-top: 10px; background: #fdfbf7; padding: 10px 15px; border-radius: 8px; border: 1px solid #f9eeb9; display: inline-block; }
        .star-icons i { color: var(--gold); font-size: 0.9rem; }
        .star-icons .fa-star.empty { color: #dfe6e9; }
        .rating-comment { margin: 5px 0 0 0 !important; font-size: 0.85rem !important; color: var(--dark) !important; font-style: italic; font-weight: 400 !important; }

        .order-meta { text-align: right; min-width: 120px; }
        .order-amount { font-size: 1.3rem; font-weight: 800; color: var(--success); margin: 0 0 5px 0; }
        .pay-method { font-size: 0.75rem; background: #edf2f7; padding: 3px 8px; border-radius: 6px; font-weight: 700; color: var(--dark); }

        /* --- STATUS BADGES --- */
        .status-badge { display: inline-block; padding: 6px 12px; border-radius: 8px; font-size: 0.8rem; font-weight: 700; text-align: center; min-width: 130px; }
        .status-pending { background: rgba(253, 203, 110, 0.2); color: #e17055; }
        .status-active { background: rgba(9, 132, 227, 0.1); color: var(--theme); }
        .status-delivered { background: rgba(0, 184, 148, 0.1); color: var(--success); }
        .status-cancelled { background: rgba(255, 118, 117, 0.1); color: var(--danger); text-decoration: line-through; }

        .empty-state { text-align: center; padding: 50px 20px; color: var(--text-muted); }
        .empty-state i { font-size: 4rem; color: #dfe6e9; margin-bottom: 15px; }
        .empty-state h2 { margin: 0; color: var(--dark); }
    </style>
</head>
<body>

    <div class="admin-header">
        <a href="HotelDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
        <h1 class="header-title">Income & Transactions</h1>
    </div>

    <div class="container">

    <%
        // 1. Get Filters from URL
        String filter = request.getParameter("filter");
        if (filter == null || filter.trim().isEmpty()) {
            filter = "today"; // Default view
        }
        
        String searchCustomer = request.getParameter("searchCustomer");
        boolean isSearching = (searchCustomer != null && !searchCustomer.trim().isEmpty());

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        int listOrderCount = 0;
        double todayRevenue = 0.0;
        double monthRevenue = 0.0;
        double allTimeRevenue = 0.0;
        
        StringBuilder ordersHtml = new StringBuilder();
        SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
        String listTitle = "";

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

            // --- 2. CALCULATE GLOBAL DASHBOARD STATS (Always accurate, ignores filters) ---
            
            // Month Income
            String sqlMonth = "SELECT NVL(SUM(TOTAL_AMOUNT), 0) FROM orders WHERE ORDER_DATE >= TRUNC(SYSDATE, 'MM') AND ORDER_STATUS NOT IN ('Cancelled', 'Not Delivered')";
            pstmt = conn.prepareStatement(sqlMonth);
            rs = pstmt.executeQuery();
            if(rs.next()) { monthRevenue = rs.getDouble(1); }
            rs.close(); pstmt.close();

            // All-Time Income
            String sqlAllTime = "SELECT NVL(SUM(TOTAL_AMOUNT), 0) FROM orders WHERE ORDER_STATUS NOT IN ('Cancelled', 'Not Delivered')";
            pstmt = conn.prepareStatement(sqlAllTime);
            rs = pstmt.executeQuery();
            if(rs.next()) { allTimeRevenue = rs.getDouble(1); }
            rs.close(); pstmt.close();

            // Today's Income
            String sqlTodayRev = "SELECT NVL(SUM(TOTAL_AMOUNT), 0) FROM orders WHERE TRUNC(ORDER_DATE) = TRUNC(SYSDATE) AND ORDER_STATUS NOT IN ('Cancelled', 'Not Delivered')";
            pstmt = conn.prepareStatement(sqlTodayRev);
            rs = pstmt.executeQuery();
            if(rs.next()) { todayRevenue = rs.getDouble(1); }
            rs.close(); pstmt.close();


            // --- 3. DYNAMIC LIST QUERY WITH RATINGS (Based on Card Click & Search) ---
            
            // Note the LEFT JOIN and the "o." prefixes to specify which table to filter by!
            String sqlList = "SELECT o.*, r.STARS, r.COMMENTS FROM orders o LEFT JOIN rating r ON o.ORDER_ID = r.ORDER_ID WHERE 1=1 ";
            
            // Apply Date Filter based on Card Click
            if (filter.equals("month")) {
                sqlList += "AND o.ORDER_DATE >= TRUNC(SYSDATE, 'MM') ";
                listTitle = "This Month's Transactions";
            } else if (filter.equals("all")) {
                // No date restriction for all-time
                listTitle = "All-Time Transactions";
            } else {
                // Default to today
                sqlList += "AND TRUNC(o.ORDER_DATE) = TRUNC(SYSDATE) ";
                listTitle = "Today's Transactions";
            }

            // Apply Search Filter if active
            if (isSearching) {
                sqlList += "AND LOWER(o.CUSTOMER_EMAIL) LIKE LOWER(?) ";
                listTitle = "Search Results for '" + searchCustomer + "'";
            }
            
            sqlList += "ORDER BY o.ORDER_DATE DESC";
            
            pstmt = conn.prepareStatement(sqlList);
            if (isSearching) {
                pstmt.setString(1, "%" + searchCustomer.trim() + "%");
            }
            
            rs = pstmt.executeQuery();

            while (rs.next()) {
                listOrderCount++;
                int orderId = rs.getInt("ORDER_ID");
                String customer = rs.getString("CUSTOMER_EMAIL");
                double amount = rs.getDouble("TOTAL_AMOUNT");
                String items = rs.getString("ITEMS");
                String status = rs.getString("ORDER_STATUS");
                String payOption = rs.getString("PAYOPTION");
                Timestamp orderDate = rs.getTimestamp("ORDER_DATE");
                
                // Fetch Rating Data
                int dbStars = rs.getInt("STARS");
                boolean hasRating = !rs.wasNull(); 
                String dbComments = rs.getString("COMMENTS");
                
                String dateStr = (orderDate != null) ? dateTimeFormat.format(orderDate) : "--/--/----";
                if(payOption == null) payOption = "COD";

                String badgeClass = "status-active";
                if (status.equalsIgnoreCase("Pending Acceptance") || status.equalsIgnoreCase("Waiting for Rider")) {
                    badgeClass = "status-pending";
                } else if (status.equalsIgnoreCase("Delivered") || status.equalsIgnoreCase("Final Delivered")) {
                    badgeClass = "status-delivered";
                } else if (status.equalsIgnoreCase("Cancelled") || status.equalsIgnoreCase("Not Delivered")) {
                    badgeClass = "status-cancelled";
                }

                // Build HTML
                ordersHtml.append("<div class='order-card'>")
                          .append("<div class='order-main'>")
                          .append("<h3 class='order-id'>Order #").append(orderId).append(" <span class='order-date-time'><i class='far fa-clock'></i> ").append(dateStr).append("</span></h3>")
                          .append("<p class='order-items'>").append(items != null ? items : "Custom Items").append("</p>")
                          .append("<p class='order-customer'><i class='fas fa-user'></i> ").append(customer).append("</p>");
                          
                // Append Rating Box if available
                if (hasRating) {
                    ordersHtml.append("<div class='item-rating'><div class='star-icons'>");
                    for(int i=1; i<=5; i++) {
                        if(i <= dbStars) ordersHtml.append("<i class='fas fa-star'></i>");
                        else ordersHtml.append("<i class='fas fa-star empty'></i>");
                    }
                    ordersHtml.append("</div>");
                    
                    if (dbComments != null && !dbComments.trim().isEmpty()) {
                        ordersHtml.append("<p class='rating-comment'>\"").append(dbComments).append("\"</p>");
                    }
                    ordersHtml.append("</div>");
                }

                ordersHtml.append("</div>") // Close order-main
                          .append("<div class='status-badge ").append(badgeClass).append("'>").append(status).append("</div>")
                          .append("<div class='order-meta'>")
                          .append("<h3 class='order-amount'>₹").append(String.format("%.2f", amount)).append("</h3>")
                          .append("<span class='pay-method'>").append(payOption.toUpperCase()).append("</span>")
                          .append("</div>")
                          .append("</div>");
            }
    %>

        <div class="summary-grid">
            <a href="Torder.jsp?filter=today" class="summary-card revenue <%= filter.equals("today") ? "active-filter" : "" %>" title="Click to view Today's orders">
                <div class="summary-icon"><i class="fas fa-rupee-sign"></i></div>
                <div class="summary-info">
                    <h3>₹<%= String.format("%.2f", todayRevenue) %></h3>
                    <p>Today's Income</p>
                </div>
            </a>
            <a href="Torder.jsp?filter=month" class="summary-card month <%= filter.equals("month") ? "active-filter" : "" %>" title="Click to view This Month's orders">
                <div class="summary-icon"><i class="fas fa-calendar-alt"></i></div>
                <div class="summary-info">
                    <h3>₹<%= String.format("%.2f", monthRevenue) %></h3>
                    <p>Month's Income</p>
                </div>
            </a>
            <a href="Torder.jsp?filter=all" class="summary-card all-time <%= filter.equals("all") ? "active-filter" : "" %>" title="Click to view All-Time orders">
                <div class="summary-icon"><i class="fas fa-chart-line"></i></div>
                <div class="summary-info">
                    <h3>₹<%= String.format("%.2f", allTimeRevenue) %></h3>
                    <p>All-Time Income</p>
                </div>
            </a>
        </div>

        <div class="list-header">
            <h2 class="section-title"><%= listTitle %> (<%= listOrderCount %> orders)</h2>

            <form action="Torder.jsp" method="GET" class="search-form">
                <input type="hidden" name="filter" value="<%= filter %>"> 
                <input type="text" name="searchCustomer" class="search-input" placeholder="Search customer email..." value="<%= isSearching ? searchCustomer : "" %>">
                <button type="submit" class="search-btn"><i class="fas fa-search"></i></button>
                <% if (isSearching) { %>
                    <a href="Torder.jsp?filter=<%= filter %>" class="clear-btn">Clear</a>
                <% } %>
            </form>
        </div>

        <% if (listOrderCount > 0) { %>
            <%= ordersHtml.toString() %>
        <% } else { %>
            <div class="empty-state">
                <i class="fas fa-folder-open"></i>
                <h2>No Transactions Found</h2>
                <p>There are no orders matching your current filter or search.</p>
            </div>
        <% } %>

    <%
        } catch (Exception e) {
            out.println("<div style='color:red; padding: 20px; background: white; border-radius: 10px;'>Database Error: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    %>

    </div>

</body>
</html>