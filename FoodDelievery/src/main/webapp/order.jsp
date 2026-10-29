<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="10">
    <title>Kitchen Display | FoodieDash Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --dark: #2d3436; --light: #f9f9fb; --white: #ffffff;
            --text-muted: #636e72; --theme: #0984e3; --success: #27ae60; --warning: #f39c12;
        }
        body { font-family: 'Poppins', sans-serif; margin: 0; background-color: var(--light); padding: 20px; }

        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 25px; background: var(--white); padding: 20px; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .header-left { display: flex; align-items: center; gap: 15px; }
        .back-btn { color: var(--dark); font-size: 1.5rem; text-decoration: none; transition: 0.2s; }
        .back-btn:hover { color: var(--theme); transform: translateX(-3px); }
        .page-header h1 { margin: 0; color: var(--dark); font-weight: 800; font-size: 1.5rem;}
        
        .refresh-btn { background: var(--theme); color: white; border: none; padding: 10px 20px; border-radius: 8px; font-family: 'Poppins'; font-weight: 600; cursor: pointer; transition: 0.2s; text-decoration: none;}
        .refresh-btn:hover { background: #076ebf; transform: translateY(-2px); }

        .table-container { background: var(--white); border-radius: 15px; padding: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 900px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #edf2f7; }
        th { background-color: #f8fafc; color: var(--text-muted); font-weight: 600; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 0.5px; }
        td { color: var(--dark); font-size: 0.95rem; }
        
        tr:hover { background-color: #f8fafc; }

        .status-badge { padding: 6px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 700; display: inline-block; min-width: 120px; text-align: center; }
        .status-waiting { background: rgba(243, 156, 18, 0.1); color: var(--warning); }
        .status-prepared { background: rgba(9, 132, 227, 0.1); color: var(--theme); }
        
        .empty-state { text-align: center; padding: 60px 20px; }
        .empty-state i { font-size: 4rem; color: var(--success); opacity: 0.3; margin-bottom: 15px; }
    </style>
</head>
<body>

    <div class="page-header">
        <div class="header-left">
            <a href="HotelDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
            <h1><i class="fas fa-fire-burner" style="color: var(--theme);"></i> Kitchen Display System</h1>
        </div>
        <a href="order.jsp" class="refresh-btn"><i class="fas fa-sync-alt"></i> Refresh Screen</a>
    </div>

    <div class="table-container">
        <table>
           <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Rider Info</th>
                    <th>Qty</th>
                    <th>Item Names</th> 
                    <th>Amount</th>
                    <th>Payment</th>
                    <th>Order Time</th>
                    <th>Live Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs = null;
                    boolean hasActiveOrders = false;
                    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");

                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");
                        
                        // FETCH ONLY ACTIVE ORDERS (Ignore Dispatched and Delivered)
                        String fetchSql = "SELECT * FROM orders WHERE ORDER_STATUS IN ('Pending Acceptance', 'Waiting for Rider', 'Being Prepared') ORDER BY ORDER_DATE DESC";
                        pstmt = conn.prepareStatement(fetchSql);
                        rs = pstmt.executeQuery();
                        
                        while(rs.next()) {
                            hasActiveOrders = true;
                            int orderId = rs.getInt("ORDER_ID");
                            String customerEmail = rs.getString("CUSTOMER_EMAIL");
                            int riderId = rs.getInt("RIDER_ID");
                            double totalAmount = rs.getDouble("TOTAL_AMOUNT");
                            String quant = rs.getString("QUANT");
                            String itemNames = rs.getString("ITEMS");
                            Timestamp orderDate = rs.getTimestamp("ORDER_DATE");
                            String status = rs.getString("ORDER_STATUS");
                            String payOption = rs.getString("PAYOPTION");
                            
                            if(payOption == null) payOption = "COD";
                            String displayRider = (rs.wasNull() || riderId == 0) ? "<span style='color: #a0aec0;'><i class='fas fa-spinner fa-spin'></i> Assigning...</span>" : "Rider #" + riderId;

                            String badgeClass = "status-waiting";
                            String icon = "<i class='fas fa-clock'></i>";
                            
                            if(status != null && status.equalsIgnoreCase("Being Prepared")) { 
                                badgeClass = "status-prepared"; 
                                icon = "<i class='fas fa-fire-burner'></i>"; 
                            }
                %>
                <tr>
                    <td><strong>#<%= orderId %></strong></td>
                    <td style="font-size: 0.85rem;"><%= customerEmail %></td>
                    <td><%= displayRider %></td>
                    <td><strong style="color: var(--dark);"><%= quant %></strong></td>
                    <td><strong style="color: var(--theme);"><%= itemNames != null ? itemNames : "N/A" %></strong></td>
                    <td>₹<%= String.format("%.2f", totalAmount) %></td>
                    <td><span style="background:#edf2f7; padding:4px 8px; border-radius:4px; font-size:0.85rem; font-weight:bold;"><%= payOption.toUpperCase() %></span></td>
                    <td style="font-size: 0.85rem; color: #636e72;"><%= timeFormat.format(orderDate) %></td>
                    <td><span class="status-badge <%= badgeClass %>"><%= icon %> <%= status %></span></td>
                </tr>
                <%
                        } // end while 

                        if (!hasActiveOrders) {
                %>
                    <tr>
                        <td colspan="9">
                            <div class="empty-state">
                                <i class="fas fa-check-double"></i>
                                <h2>All Caught Up!</h2>
                                <p>No active orders in the kitchen right now.</p>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='9'><p style='color:red; text-align:center;'>Error: " + e.getMessage() + "</p></td></tr>");
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
                    }
                %>
            </tbody>
        </table>
    </div>

</body>
</html>