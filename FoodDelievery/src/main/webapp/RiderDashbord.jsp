<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rider Dashboard | FoodieDash</title>
    
    <meta http-equiv="refresh" content="10">

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        /* --- CORE STYLES --- */
        :root { --dark: #2d3436; --light: #f4f6f8; --white: #ffffff; --text-muted: #636e72; --theme: #6c5ce7; --theme-accent: #a29bfe; --success: #00b894; --danger: #ff7675; --warning: #f39c12; }
        body { font-family: 'Poppins', sans-serif; margin: 0; background-color: var(--light); padding-bottom: 80px; overflow-x: hidden; }
        
        /* --- SIDEBAR MENU --- */
        .sidebar {
            position: fixed; top: 0; left: -280px; width: 280px; height: 100vh;
            background: var(--white); box-shadow: 4px 0 15px rgba(0,0,0,0.1);
            z-index: 2000; transition: 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            display: flex; flex-direction: column;
        }
        .sidebar.active { left: 0; }
        .sidebar-header {
            padding: 30px 20px; background: linear-gradient(135deg, var(--theme), var(--theme-accent));
            color: white; display: flex; justify-content: space-between; align-items: center;
        }
        .sidebar-header h2 { margin: 0; font-size: 1.5rem; font-weight: 800; }
        .close-btn { color: white; font-size: 1.5rem; cursor: pointer; border: none; background: none; }
        
        .sidebar-links { padding: 20px 0; display: flex; flex-direction: column; gap: 10px; flex-grow: 1; }
        .sidebar-links a {
            text-decoration: none; color: var(--dark); font-weight: 600; font-size: 1.1rem;
            padding: 15px 25px; display: flex; align-items: center; gap: 15px; transition: 0.2s;
        }
        .sidebar-links a i { width: 25px; text-align: center; color: var(--theme); font-size: 1.3rem; }
        .sidebar-links a:hover { background: rgba(108, 92, 231, 0.1); color: var(--theme); padding-left: 30px; }
        
        /* Logout Link Styling */
        .logout-link { margin-top: auto; border-top: 1px solid #edf2f7; color: var(--danger) !important; }
        .logout-link i { color: var(--danger) !important; }
        .logout-link:hover { background: rgba(255, 118, 117, 0.1) !important; color: var(--danger) !important; }

        /* Overlay for when sidebar is open */
        .overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); z-index: 1500; display: none; backdrop-filter: blur(3px);
        }
        .overlay.active { display: block; }

        /* --- HEADER --- */
        .rider-header { 
            background: linear-gradient(135deg, var(--theme), var(--theme-accent)); 
            padding: 20px 20px; color: var(--white); display: flex; justify-content: space-between; 
            align-items: center; box-shadow: 0 4px 15px rgba(108, 92, 231, 0.3); 
            border-bottom-left-radius: 20px; border-bottom-right-radius: 20px; 
        }
        
        .header-left { display: flex; align-items: center; gap: 15px; }
        .menu-btn { color: white; font-size: 1.5rem; cursor: pointer; background: none; border: none; padding: 0; }
        .header-title { margin: 0; font-size: 1.4rem; font-weight: 800; display: flex; align-items: center; gap: 8px; }
        
        .header-right { display: flex; align-items: center; gap: 15px; }
        .refresh-btn { background: rgba(255,255,255,0.2); color: var(--white); text-decoration: none; padding: 8px 16px; border-radius: 10px; font-weight: 600; transition: 0.2s; }
        .refresh-btn:hover { background: var(--theme-accent); }
        
        /* Cute Profile Icon */
        .profile-icon {
            width: 45px; height: 45px; border-radius: 50%; background: var(--white);
            display: flex; align-items: center; justify-content: center;
            color: var(--theme); font-size: 1.5rem; text-decoration: none;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); transition: 0.3s;
            border: 2px solid transparent;
        }
        .profile-icon:hover { transform: scale(1.1); border-color: var(--theme-accent); }
        
        /* --- DASHBOARD CONTAINER --- */
        .container { padding: 25px 20px; max-width: 800px; margin: auto; }
        .section-title { font-size: 1.2rem; color: var(--dark); margin-bottom: 15px; font-weight: 700; display: flex; align-items: center; gap: 10px; }
        
        /* --- ORDER CARDS --- */
        .order-card { background: var(--white); border-radius: 16px; padding: 20px; margin-bottom: 20px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); border-left: 5px solid var(--theme); transition: 0.3s; animation: popIn 0.4s ease-out; }
        @keyframes popIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .order-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px dashed #dfe6e9; padding-bottom: 10px; margin-bottom: 10px; }
        .order-id { font-weight: 800; color: var(--dark); font-size: 1.1rem; }
        .order-amount { font-weight: 800; color: var(--success); font-size: 1.2rem; }
        .order-details p { margin: 5px 0; color: var(--text-muted); font-size: 0.95rem; }
        .order-details strong { color: var(--dark); }
        
        /* --- ACTION BUTTONS --- */
        .action-btns { display: flex; gap: 15px; margin-top: 20px; }
        .btn { flex: 1; padding: 12px; border: none; border-radius: 10px; font-size: 1rem; font-weight: 700; cursor: pointer; transition: 0.2s; color: white; width: 100%;}
        .btn-accept { background: var(--success); box-shadow: 0 4px 10px rgba(0, 184, 148, 0.3); }
        .btn-accept:hover { transform: translateY(-2px); background: #00a885; }
        .btn-dispatch { background: var(--theme); box-shadow: 0 4px 10px rgba(108, 92, 231, 0.3); }
        .btn-dispatch:hover { transform: translateY(-2px); background: #5a4bcf; }
        .btn-reject { background: var(--white); color: var(--danger); border: 2px solid var(--danger); }
        .btn-reject:hover { background: rgba(255, 118, 117, 0.1); }

        /* --- EMPTY STATE --- */
        .empty-state { text-align: center; padding: 40px 20px; color: var(--text-muted); background: var(--white); border-radius: 16px; border: 1px dashed #cbd5e1; }
        .empty-state i { font-size: 3rem; color: #dfe6e9; margin-bottom: 15px; }

        /* --- STATUS BADGES --- */
        .status-badge { display: inline-block; padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; font-weight: 700; margin-top: 10px; }
        .status-prepared { background: rgba(108, 92, 231, 0.1); color: var(--theme); border: 1px solid rgba(108, 92, 231, 0.2); }
        .status-dispatch { background: rgba(0, 184, 148, 0.1); color: var(--success); border: 1px solid rgba(0, 184, 148, 0.2); animation: pulse 2s infinite; }
        
        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(0, 184, 148, 0.4); }
            70% { box-shadow: 0 0 0 10px rgba(0, 184, 148, 0); }
            100% { box-shadow: 0 0 0 0 rgba(0, 184, 148, 0); }
        }
    </style>
</head>
<body>

    <%
        // Session Authorization
        String riderName = (String) session.getAttribute("riderName");
        if (riderName == null || riderName.trim().isEmpty()) {
            response.sendRedirect("login1.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int currentRiderId = -1;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

            // Fetch the Rider's ID
            pstmt = conn.prepareStatement("SELECT RIDER_ID FROM riders WHERE RIDER_NAME = ?");
            pstmt.setString(1, riderName);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                currentRiderId = rs.getInt("RIDER_ID");
            }
            pstmt.close(); rs.close();

            // Handle POST Actions
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                
                // --- LOGOUT LOGIC (Set to Offline) ---
                if ("logout".equals(request.getParameter("action"))) {
                    String offlineSql = "UPDATE riders SET CURRENT_STATUS = 'offline' WHERE RIDER_ID = ?";
                    pstmt = conn.prepareStatement(offlineSql);
                    pstmt.setInt(1, currentRiderId);
                    pstmt.executeUpdate();
                    pstmt.close();
                    
                    session.invalidate(); // Destroy session
                    response.sendRedirect("login1.jsp");
                    return;
                }
                
                // ACCEPT ORDER
                if (request.getParameter("acceptOrderId") != null) {
                    int orderIdToAccept = Integer.parseInt(request.getParameter("acceptOrderId"));
                    String updateSql = "UPDATE orders SET ORDER_STATUS = 'Being Prepared' WHERE ORDER_ID = ? AND (RIDER_ID = ? OR RIDER_ID IS NULL)";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setInt(1, orderIdToAccept);
                    pstmt.setInt(2, currentRiderId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
                
                // REJECT ORDER
                if (request.getParameter("rejectOrderId") != null) {
                    int orderIdToReject = Integer.parseInt(request.getParameter("rejectOrderId"));
                    int nextRiderId = 0;
                    String findNextSql = "SELECT RIDER_ID FROM (SELECT RIDER_ID FROM riders WHERE CURRENT_STATUS = 'online' AND RIDER_ID != ? ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1";
                    pstmt = conn.prepareStatement(findNextSql);
                    pstmt.setInt(1, currentRiderId);
                    rs = pstmt.executeQuery();
                    if(rs.next()) nextRiderId = rs.getInt(1);
                    pstmt.close(); rs.close();

                    String reassignSql;
                    if (nextRiderId > 0) {
                        reassignSql = "UPDATE orders SET RIDER_ID = ? WHERE ORDER_ID = ?";
                        pstmt = conn.prepareStatement(reassignSql);
                        pstmt.setInt(1, nextRiderId);
                        pstmt.setInt(2, orderIdToReject);
                    } else {
                        reassignSql = "UPDATE orders SET RIDER_ID = NULL, ORDER_STATUS = 'Waiting for Rider' WHERE ORDER_ID = ?";
                        pstmt = conn.prepareStatement(reassignSql);
                        pstmt.setInt(1, orderIdToReject);
                    }
                    pstmt.executeUpdate();
                    pstmt.close();
                }

                // MARK DISPATCHED
                if (request.getParameter("markDispatchedId") != null) {
                    int orderIdToDispatch = Integer.parseInt(request.getParameter("markDispatchedId"));
                    String dispatchSql = "UPDATE orders SET ORDER_STATUS = 'Dispatched' WHERE ORDER_ID = ? AND RIDER_ID = ?";
                    pstmt = conn.prepareStatement(dispatchSql);
                    pstmt.setInt(1, orderIdToDispatch);
                    pstmt.setInt(2, currentRiderId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }

                // MARK DELIVERED
                if (request.getParameter("markDeliveredId") != null) {
                    int orderIdToDeliver = Integer.parseInt(request.getParameter("markDeliveredId"));
                    String deliverSql = "UPDATE orders SET ORDER_STATUS = 'Delivered' WHERE ORDER_ID = ? AND RIDER_ID = ?";
                    pstmt = conn.prepareStatement(deliverSql);
                    pstmt.setInt(1, orderIdToDeliver);
                    pstmt.setInt(2, currentRiderId);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
                
                // Redirect to avoid form resubmission on page reload
                response.sendRedirect("RiderDashbord.jsp");
                return;
            }
    %>

    <div class="overlay" id="overlay" onclick="toggleSidebar()"></div>

    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2>FoodieDash</h2>
            <button class="close-btn" onclick="toggleSidebar()"><i class="fas fa-times"></i></button>
        </div>
        <div class="sidebar-links">
            <a href="RiderDashbord.jsp"><i class="fas fa-home"></i> Home</a>
            <a href="Tincome.jsp"><i class="fas fa-wallet"></i> Today's Income</a>
            <a href="Mincome.jsp"><i class="fas fa-chart-line"></i> Monthly Income</a>
            
            <form method="POST" action="RiderDashbord.jsp" style="margin-top: auto; display: contents;">
                <input type="hidden" name="action" value="logout">
                <button type="submit" class="logout-link" style="background:none; border:none; width:100%; text-align:left; cursor:pointer; font-family:'Poppins'; padding:15px 25px; font-size:1.1rem; font-weight:600; display:flex; align-items:center; gap:15px; border-top:1px solid #edf2f7; transition:0.2s;">
                    <i class="fas fa-power-off"></i> Go Offline & Logout
                </button>
            </form>
        </div>
    </div>

    <div class="rider-header">
        <div class="header-left">
            <button class="menu-btn" onclick="toggleSidebar()"><i class="fas fa-bars"></i></button>
            <h1 class="header-title">Dashboard</h1>
        </div>
        
        <div class="header-right">
            <a href="./RiderDashbord.jsp" class="refresh-btn"><i class="fas fa-sync-alt"></i> Refresh</a> 
            <a href="./RiderProfile.jsp" class="profile-icon" title="My Profile"><i class="fas fa-user-astronaut"></i></a>
        </div>
    </div>

    <div class="container">
        
        <div class="section-title"><i class="fas fa-bell" style="color: var(--warning);"></i> Incoming Offers</div>

        <%
            // Fetch Incoming Orders
            String pendingSql = "SELECT o.*, c.NAME, c.PHONE, c.ADDRESS FROM orders o LEFT JOIN Customer c ON o.CUSTOMER_EMAIL = c.EMAIL WHERE (o.RIDER_ID = ? AND o.ORDER_STATUS = 'Pending Acceptance') OR (o.RIDER_ID IS NULL AND o.ORDER_STATUS = 'Waiting for Rider') ORDER BY o.ORDER_DATE DESC";
            pstmt = conn.prepareStatement(pendingSql);
            pstmt.setInt(1, currentRiderId);
            rs = pstmt.executeQuery();
            boolean hasPending = false;

            while(rs.next()) {
                hasPending = true;
                int orderId = rs.getInt("ORDER_ID");
                String items = rs.getString("QUANT");
                String payOption = rs.getString("PAYOPTION");
                if(payOption == null) payOption = "COD";
                
                String custName = rs.getString("NAME");
                String custPhone = rs.getString("PHONE");
                String custAddress = rs.getString("ADDRESS");
                if(custName == null) custName = "Customer";
                
                double totalAmount = rs.getDouble("TOTAL_AMOUNT");
                String formattedEarning = String.format("%.2f", totalAmount * 0.05);
        %>
        <div class="order-card" style="border-left-color: var(--warning);">
            <div class="order-header">
                <span class="order-id">Order #<%= orderId %></span>
                <span class="order-amount" style="color: var(--warning);">Earn: ₹<%= formattedEarning %></span>
            </div>
            
            <div class="order-details">
                <p><strong><i class="fas fa-user"></i> Name:</strong> <%= custName %></p>
                <p><strong><i class="fas fa-phone"></i> Phone:</strong> <%= custPhone != null ? custPhone : "N/A" %></p>
                <p><strong><i class="fas fa-map-marker-alt"></i> Address:</strong> <%= custAddress != null ? custAddress : "N/A" %></p>
                <hr style="border: 0; border-top: 1px dashed #dfe6e9; margin: 10px 0;">
                <p><strong>Items:</strong> <%= items %></p>
                <p><strong>Payment:</strong> <span style="background:#eee; padding:2px 8px; border-radius:4px;"><%= payOption.toUpperCase() %></span></p>
            </div>
            
            <div class="action-btns">
                <form action="RiderDashbord.jsp" method="POST" style="flex: 1; display: flex;">
                    <input type="hidden" name="rejectOrderId" value="<%= orderId %>">
                    <button type="submit" class="btn btn-reject">Reject</button>
                </form>
                <form action="RiderDashbord.jsp" method="POST" style="flex: 1; display: flex;">
                    <input type="hidden" name="acceptOrderId" value="<%= orderId %>">
                    <button type="submit" class="btn btn-accept">Accept Order</button>
                </form>
            </div>
        </div>
        <% } pstmt.close(); rs.close(); %>

        <% if (!hasPending) { %>
            <div class="empty-state">
                <i class="fas fa-search-location"></i>
                <p>No new offers right now.</p>
                </div>
        <% } %>

        <div class="section-title" style="margin-top: 40px;"><i class="fas fa-route" style="color: var(--theme);"></i> My Active Deliveries</div>

        <%
            // Fetch Active Deliveries
            String activeSql = "SELECT o.*, c.NAME, c.PHONE, c.ADDRESS FROM orders o LEFT JOIN Customer c ON o.CUSTOMER_EMAIL = c.EMAIL WHERE o.RIDER_ID = ? AND o.ORDER_STATUS IN ('Being Prepared', 'Ready for Dispatch', 'Dispatched') ORDER BY o.ORDER_DATE DESC";
            pstmt = conn.prepareStatement(activeSql);
            pstmt.setInt(1, currentRiderId);
            rs = pstmt.executeQuery();
            boolean hasActive = false;

            while(rs.next()) {
                hasActive = true;
                int orderId = rs.getInt("ORDER_ID");
                String items = rs.getString("QUANT");
                String payOption = rs.getString("PAYOPTION");
                if(payOption == null) payOption = "COD";
                String status = rs.getString("ORDER_STATUS");
                
                String custName = rs.getString("NAME");
                String custPhone = rs.getString("PHONE");
                String custAddress = rs.getString("ADDRESS");
                if(custName == null) custName = "Customer";
                
                double totalAmount = rs.getDouble("TOTAL_AMOUNT");
                String formattedEarning = String.format("%.2f", totalAmount * 0.05);

                boolean isDispatched = status.equalsIgnoreCase("Dispatched") || status.equalsIgnoreCase("Ready for Dispatch");
                String badgeClass = isDispatched ? "status-dispatch" : "status-prepared";
                String icon = isDispatched ? "<i class='fas fa-motorcycle'></i>" : "<i class='fas fa-fire-burner'></i>";
        %>
        <div class="order-card" style="border-left-color: var(--theme);">
            <div class="order-header">
                <span class="order-id">Order #<%= orderId %></span>
                <span class="order-amount">Earn: ₹<%= formattedEarning %></span>
            </div>
            
            <div class="order-details">
                <p><strong><i class="fas fa-user"></i> Name:</strong> <%= custName %></p>
                <p><strong><i class="fas fa-phone"></i> Phone:</strong> <%= custPhone != null ? custPhone : "N/A" %></p>
                <p><strong><i class="fas fa-map-marker-alt"></i> Address:</strong> <%= custAddress != null ? custAddress : "N/A" %></p>
                <hr style="border: 0; border-top: 1px dashed #dfe6e9; margin: 10px 0;">
                <p><strong>Items:</strong> <%= items %></p>
                <p><strong>Payment:</strong> <span style="background:#eee; padding:2px 8px; border-radius:4px;"><%= payOption.toUpperCase() %></span></p>
                <div class="status-badge <%= badgeClass %>"><%= icon %> <%= status %></div>
            </div>
            
            <div class="action-btns">
                <% if(isDispatched) { %>
                    <form action="RiderDashbord.jsp" method="POST" style="flex: 1; display: flex;">
                        <input type="hidden" name="markDeliveredId" value="<%= orderId %>">
                        <button type="submit" class="btn btn-accept"><i class="fas fa-map-marker-alt"></i> Mark Delivered</button>
                    </form>
                <% } else { %>
                    <form action="RiderDashbord.jsp" method="POST" style="flex: 1; display: flex;">
                        <input type="hidden" name="markDispatchedId" value="<%= orderId %>">
                        <button type="submit" class="btn btn-dispatch"><i class="fas fa-box-open"></i> Mark Dispatched</button>
                    </form>
                <% } %>
            </div>
        </div>
        <% } %>

        <% if (!hasActive) { %>
            <div class="empty-state">
                <i class="fas fa-box"></i>
                <p>You have no active deliveries currently.</p>
            </div>
        <% } %>

    </div>

    <%
        } catch (Exception e) {
            out.println("<p style='color:red;'>Database Error: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    %>

    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('active');
            document.getElementById('overlay').classList.toggle('active');
        }
    </script>

</body>
</html>