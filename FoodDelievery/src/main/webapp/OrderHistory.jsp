<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    // 1. Session Check
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null || userEmail.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Handle Rating Form Submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("rateOrder".equals(action)) {
            String orderIdStr = request.getParameter("orderId");
            String starsStr = request.getParameter("stars");
            String comments = request.getParameter("comments");

            Connection conn = null;
            PreparedStatement pstmt = null;
            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");
                
                String sql = "INSERT INTO RATING (ORDER_ID, STARS, COMMENTS) VALUES (?, ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, Integer.parseInt(orderIdStr));
                pstmt.setInt(2, Integer.parseInt(starsStr));
                pstmt.setString(3, comments);
                
                pstmt.executeUpdate();
            } catch (Exception e) {
                System.out.println("Rating Error: " + e.getMessage());
            } finally {
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
            // Redirect back to this same page to prevent form resubmission on refresh
            response.sendRedirect(request.getRequestURI());
            return;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order History | FoodieDash</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root { 
            --dark: #2d3436; 
            --light: #f9f9fb; 
            --white: #ffffff; 
            --text-muted: #636e72; 
            --theme: #6c5ce7; 
            --theme-accent: #a29bfe; 
            --success: #00b894; 
            --danger: #ff7675; 
            --warning: #f39c12;
            --gold: #f1c40f;
        }
        
        body { 
            font-family: 'Poppins', sans-serif; 
            margin: 0; 
            min-height: 100vh; 
            background: var(--light); 
            padding: 20px; 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
        }

        /* --- HEADER --- */
        .header { 
            width: 100%; 
            max-width: 800px; 
            display: flex; 
            align-items: center; 
            background: linear-gradient(135deg, var(--theme), var(--theme-accent));
            padding: 20px 25px;
            border-radius: 16px;
            box-shadow: 0 10px 20px rgba(108, 92, 231, 0.2);
            margin-bottom: 30px;
            box-sizing: border-box;
        }
        .back-btn { color: white; font-size: 1.5rem; text-decoration: none; transition: 0.2s; margin-right: 15px; }
        .back-btn:hover { transform: translateX(-5px); }
        h1 { color: white; margin: 0; font-weight: 800; font-size: 1.5rem; }

        /* --- HISTORY CONTAINER --- */
        .history-container { width: 100%; max-width: 800px; }

        /* --- ORDER CARD --- */
        .history-card { 
            background: var(--white); 
            padding: 25px; 
            border-radius: 16px; 
            box-shadow: 0 5px 15px rgba(0,0,0,0.05); 
            margin-bottom: 20px; 
            border: 1px solid #edf2f7;
            transition: transform 0.2s;
        }
        .history-card:hover { transform: translateY(-3px); box-shadow: 0 10px 25px rgba(0,0,0,0.08); }
        
        .card-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px dashed #edf2f7; padding-bottom: 15px; margin-bottom: 15px; }
        .order-id { font-size: 1.1rem; font-weight: 800; color: var(--dark); }
        .order-date { font-size: 0.9rem; color: var(--text-muted); font-weight: 600; display: flex; align-items: center; gap: 5px; }

        .card-body { display: flex; justify-content: space-between; align-items: flex-start; }
        .order-items { flex-grow: 1; padding-right: 20px; }
        .order-items p { margin: 0 0 5px 0; color: var(--dark); font-weight: 600; line-height: 1.5; }
        .order-items span { color: var(--text-muted); font-size: 0.9rem; }
        
        .order-total { text-align: right; }
        .total-amt { font-size: 1.4rem; font-weight: 800; color: var(--theme); margin: 0; }
        .pay-badge { background: #edf2f7; color: var(--dark); font-size: 0.75rem; font-weight: 700; padding: 4px 10px; border-radius: 6px; display: inline-block; margin-top: 5px; }

        /* --- STATUS BADGES --- */
        .status-badge { display: inline-block; padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; font-weight: 700; margin-top: 15px; }
        .status-success { background: rgba(0, 184, 148, 0.1); color: var(--success); }
        .status-danger { background: rgba(255, 118, 117, 0.1); color: var(--danger); }
        .status-warning { background: rgba(243, 156, 18, 0.1); color: var(--warning); }
        .status-info { background: rgba(108, 92, 231, 0.1); color: var(--theme); }

        /* --- RATING SYSTEM CSS --- */
        .rating-section { margin-top: 20px; padding-top: 15px; border-top: 2px dashed #edf2f7; }
        .rating-form { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
        .rating-form select { padding: 8px 12px; border: 1px solid #dfe6e9; border-radius: 8px; font-family: 'Poppins', sans-serif; font-weight: 600; outline: none; }
        .rating-form input[type="text"] { flex-grow: 1; padding: 8px 15px; border: 1px solid #dfe6e9; border-radius: 8px; font-family: 'Poppins', sans-serif; outline: none; min-width: 200px; }
        .rating-form button { background: var(--theme); color: white; border: none; padding: 8px 20px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: 'Poppins', sans-serif;}
        .rating-form button:hover { background: #5a4bcf; }
        
        .submitted-rating { background: #fdfbf7; padding: 12px 15px; border-radius: 10px; border: 1px solid #f9eeb9; display: flex; flex-direction: column; gap: 5px; }
        .star-icons i { color: var(--gold); font-size: 0.9rem; }
        .star-icons .fa-star.empty { color: #dfe6e9; }
        .submitted-rating p { margin: 0; font-size: 0.9rem; color: var(--dark); font-style: italic; }

        /* --- EMPTY STATE --- */
        .empty-state { text-align: center; padding: 60px 20px; background: var(--white); border-radius: 20px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .empty-state i { font-size: 4rem; color: #dfe6e9; margin-bottom: 15px; }
        .empty-state h2 { color: var(--dark); margin: 0 0 10px 0; font-weight: 800; }
        .empty-state p { color: var(--text-muted); margin-bottom: 25px; }
        .order-btn { background: var(--theme); color: white; text-decoration: none; padding: 12px 25px; border-radius: 12px; font-weight: 700; display: inline-block; transition: 0.2s; }
        .order-btn:hover { background: #5a4bcf; transform: translateY(-2px); }
    </style>
</head>
<body>

    <div class="header">
        <a href="CoustmerDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
        <h1><i class="fas fa-receipt"></i> My Order History</h1>
    </div>

    <div class="history-container">
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            boolean hasOrders = false;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

                // We use a LEFT JOIN so we pull the orders AND their ratings simultaneously!
                String sql = "SELECT o.*, r.STARS, r.COMMENTS FROM orders o LEFT JOIN rating r ON o.ORDER_ID = r.ORDER_ID WHERE o.CUSTOMER_EMAIL = ? ORDER BY o.ORDER_DATE DESC";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, userEmail);
                rs = pstmt.executeQuery();

                SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

                while(rs.next()) {
                    hasOrders = true;
                    int orderId = rs.getInt("ORDER_ID");
                    double totalAmount = rs.getDouble("TOTAL_AMOUNT");
                    String items = rs.getString("ITEMS");
                    String quant = rs.getString("QUANT");
                    String status = rs.getString("ORDER_STATUS");
                    String payOption = rs.getString("PAYOPTION");
                    Timestamp orderDate = rs.getTimestamp("ORDER_DATE");
                    
                    // Rating Data (Will be 0/null if no rating exists)
                    int dbStars = rs.getInt("STARS");
                    boolean hasRating = !rs.wasNull(); // Checks if the inner join actually found a rating
                    String dbComments = rs.getString("COMMENTS");
                    if (dbComments == null) dbComments = "";
                    
                    if(payOption == null) payOption = "COD";
                    if(items == null) items = "Food Items";
                    
                    String formattedDate = (orderDate != null) ? sdf.format(orderDate) : "Unknown Date";

                    String badgeClass = "status-info";
                    String icon = "<i class='fas fa-clock'></i>";
                    
                    if (status.equalsIgnoreCase("Final Delivered")) {
                        badgeClass = "status-success";
                        icon = "<i class='fas fa-check-circle'></i>";
                    } else if (status.equalsIgnoreCase("Not Delivered")) {
                        badgeClass = "status-danger";
                        icon = "<i class='fas fa-times-circle'></i>";
                    } else if (status.equalsIgnoreCase("Delivered") || status.equalsIgnoreCase("Dispatched") || status.equalsIgnoreCase("Ready for Dispatch")) {
                        badgeClass = "status-info";
                        icon = "<i class='fas fa-motorcycle'></i>";
                    } else {
                        badgeClass = "status-warning";
                        icon = "<i class='fas fa-fire-burner'></i>";
                    }
        %>
            
            <div class="history-card">
                <div class="card-header">
                    <span class="order-id">Order #<%= orderId %></span>
                    <span class="order-date"><i class="far fa-calendar-alt"></i> <%= formattedDate %></span>
                </div>
                
                <div class="card-body">
                    <div class="order-items">
                        <p><%= items %></p>
                        <span>Qty: <%= quant %></span>
                        <br>
                        <span class="status-badge <%= badgeClass %>"><%= icon %> <%= status %></span>
                    </div>
                    
                    <div class="order-total">
                        <h3 class="total-amt">₹<%= String.format("%.2f", totalAmount) %></h3>
                        <span class="pay-badge"><%= payOption.toUpperCase() %></span>
                    </div>
                </div>

                <% if (hasRating) { %>
                    <div class="rating-section">
                        <div class="submitted-rating">
                            <div class="star-icons">
                                <% for(int i=1; i<=5; i++) { 
                                    if(i <= dbStars) out.print("<i class='fas fa-star'></i>");
                                    else out.print("<i class='fas fa-star empty'></i>");
                                } %>
                            </div>
                            <% if (!dbComments.isEmpty()) { %>
                                <p>"<%= dbComments %>"</p>
                            <% } %>
                        </div>
                    </div>
                <% } else if (status.equalsIgnoreCase("Final Delivered")) { %>
                    <div class="rating-section">
                        <form action="" method="POST" class="rating-form">
                            <input type="hidden" name="action" value="rateOrder">
                            <input type="hidden" name="orderId" value="<%= orderId %>">
                            
                            <select name="stars" required>
                                <option value="" disabled selected>Rate order...</option>
                                <option value="5">⭐⭐⭐⭐⭐ Excellent</option>
                                <option value="4">⭐⭐⭐⭐ Good</option>
                                <option value="3">⭐⭐⭐ Average</option>
                                <option value="2">⭐⭐ Poor</option>
                                <option value="1">⭐ Terrible</option>
                            </select>
                            
                            <input type="text" name="comments" placeholder="Tell us what you thought..." maxlength="500">
                            <button type="submit">Submit</button>
                        </form>
                    </div>
                <% } %>
                
            </div>

        <%
                } // End while loop
                
                if (!hasOrders) {
        %>
            <div class="empty-state">
                <i class="fas fa-hamburger"></i>
                <h2>No Orders Yet</h2>
                <p>Looks like you haven't placed any orders with us yet!</p>
                <a href="menu.jsp" class="order-btn">Explore Menu</a>
            </div>
        <%
                }

            } catch (Exception e) {
                out.println("<p style='color:red; text-align:center;'>Database Error: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
    </div>

</body>
</html>