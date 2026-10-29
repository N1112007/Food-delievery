<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // --- 1. JAVA SESSION CART LOGIC ---
    HashMap<String, HashMap<String, String>> cart = (HashMap<String, HashMap<String, String>>) session.getAttribute("sessionCart");
    if (cart == null) {
        cart = new HashMap<>();
        session.setAttribute("sessionCart", cart);
    }

    // Handle Add & Update Actions
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        String itemId = request.getParameter("itemId");
        
        if ("add".equals(action)) {
            HashMap<String, String> item = new HashMap<>();
            item.put("name", request.getParameter("name"));
            item.put("price", request.getParameter("price"));
            item.put("img", request.getParameter("img"));
            item.put("quantity", "1");
            cart.put(itemId, item);
        } else if ("update".equals(action)) {
            int change = Integer.parseInt(request.getParameter("change"));
            if (cart.containsKey(itemId)) {
                HashMap<String, String> item = cart.get(itemId);
                int newQty = Integer.parseInt(item.get("quantity")) + change;
                if (newQty <= 0) {
                    cart.remove(itemId);
                } else {
                    item.put("quantity", String.valueOf(newQty));
                }
            }
        }
        
        response.sendRedirect("sides.jsp?focus=" + itemId);
        return;
    }

    // Calculate Floating Cart Totals
    int totalItems = 0;
    double totalPrice = 0;
    for (HashMap<String, String> item : cart.values()) {
        int qty = Integer.parseInt(item.get("quantity"));
        double price = Double.parseDouble(item.get("price"));
        totalItems += qty;
        totalPrice += (price * qty);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu | FoodieDash</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root { --dark: #2d3436; --light: #f9f9fb; --white: #ffffff; --text-muted: #636e72; --drink-theme: #0984e3; --drink-accent: #00cec9; }
        body { font-family: 'Poppins', sans-serif; margin: 0; background-color: var(--light); padding-bottom: 120px; }
        .page-header { background: var(--white); padding: 20px; display: flex; align-items: center; gap: 15px; box-shadow: 0 2px 15px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 1000; }
        .back-btn { color: var(--dark); font-size: 1.5rem; text-decoration: none; transition: 0.2s; }
        .back-btn:hover { color: var(--drink-theme); transform: translateX(-3px); }
        .page-title { margin: 0; font-size: 1.4rem; font-weight: 800; color: var(--dark); }
        .diet-icon { display: inline-block; width: 14px; height: 14px; border-radius: 3px; position: relative; margin-right: 8px; vertical-align: middle; box-sizing: border-box; }
        .menu-container { padding: 25px 20px; max-width: 1200px; margin: auto; }
        .menu-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 25px; }
        .food-card { background: var(--white); border-radius: 20px; overflow: hidden; box-shadow: 0 8px 20px rgba(0,0,0,0.04); display: flex; flex-direction: column; transition: transform 0.3s ease; border: 1px solid rgba(0,0,0,0.02); }
        .food-card:hover { transform: translateY(-8px); box-shadow: 0 15px 30px rgba(9, 132, 227, 0.2); } 
        .food-img { width: 100%; height: 200px; background-color: #dfe6e9; background-size: cover; background-position: center; }
        .food-info { padding: 20px; display: flex; flex-direction: column; flex-grow: 1; }
        .food-info h3 { margin: 0 0 8px 0; font-size: 1.2rem; color: var(--dark); font-weight: 700; display: flex; align-items: center; }
        .food-info p { margin: 0; font-size: 0.85rem; color: var(--text-muted); line-height: 1.6; flex-grow: 1; }
        .food-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; padding-top: 15px; border-top: 1px dashed #e2e8f0; height: 40px; }
        .price { font-size: 1.3rem; font-weight: 800; color: var(--drink-theme); }
        .add-btn { background: linear-gradient(135deg, var(--drink-theme), var(--drink-accent)); color: white; border: none; padding: 0 24px; height: 38px; border-radius: 20px; font-weight: 700; cursor: pointer; transition: 0.2s; box-shadow: 0 4px 10px rgba(9, 132, 227, 0.3); }
        /* Add a subtle outline so the user knows which button is focused */
        button:focus { outline: 2px solid var(--drink-theme); outline-offset: 2px; }
        .leveler { display: flex; align-items: center; justify-content: space-between; background: var(--white); border: 2px solid var(--drink-theme); border-radius: 20px; overflow: hidden; height: 36px; width: 100px; }
        .leveler form { display: contents; }
        .leveler button { background: transparent; color: var(--drink-theme); border: none; width: 35px; height: 100%; font-size: 1.2rem; font-weight: 800; cursor: pointer; }
        .leveler span { width: 30px; text-align: center; font-weight: 800; color: var(--dark); }
        .floating-cart { position: fixed; bottom: -100px; left: 50%; transform: translateX(-50%); width: 90%; max-width: 450px; background: var(--dark); color: white; padding: 16px 25px; border-radius: 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 15px 35px rgba(0,0,0,0.4); transition: bottom 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55); z-index: 9999; }
        .floating-cart.show { bottom: 25px; }
        .cart-total-price { font-size: 1.4rem; font-weight: 800; color: var(--drink-accent); }
        .view-cart-btn { background: white; color: var(--dark); text-decoration: none; padding: 10px 24px; border-radius: 25px; font-weight: 800; display: flex; align-items: center; gap: 8px; }
    </style>
</head>
<body>

    <div class="page-header">
        <a href="CoustmerDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
        <h1 class="page-title">🍟 Sides & Shareables</h1>
    </div>

    <div class="menu-container">
        <div class="menu-grid">
            
            <% 
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");
                    
                    String sql = "SELECT * FROM items";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    
                    while(rs.next()) {
                        String rawId = rs.getString("PRODUCT_ID");
                        if (rawId != null && rawId.charAt(0) == '5') {
                            
                            String itemId = "item_" + rawId; 
                            String itemName = rs.getString("ITEM_NAME");
                            String description = rs.getString("DESCRIPTION");
                            double price = rs.getDouble("PRICE");
                            String imgUrl = rs.getString("item_img");
                            String dietType = rs.getString("DietType");
                            
                            if(description == null) description = "";
                            if(imgUrl == null || imgUrl.isEmpty()) imgUrl = "https://images.unsplash.com/photo-1523472721958-978152f4d69b?auto=format&fit=crop&w=500&q=60"; 
                            String dietColor = (dietType != null && dietType.equalsIgnoreCase("Non-Veg")) ? "#e74c3c" : "#218c74";
                            
                            boolean inCart = cart.containsKey(itemId);
                            String currentQty = inCart ? cart.get(itemId).get("quantity") : "0";
                            
                            // Check if this is the item the user just clicked
                            String focusParam = request.getParameter("focus");
                            String autoFocusAttr = (focusParam != null && focusParam.equals(itemId)) ? "autofocus" : "";
                %>
                            
                            <div class="food-card">
                                <div class="food-img" style="background-image: url('<%= imgUrl %>');"></div>
                                <div class="food-info">
                                    <h3>
                                        <span class="diet-icon" style="border: 2px solid <%= dietColor %>;">
                                            <span style="content:''; position:absolute; width:7px; height:7px; background-color:<%= dietColor %>; border-radius:50%; top:50%; left:50%; transform:translate(-50%, -50%);"></span>
                                        </span> 
                                        <%= itemName %>
                                    </h3>
                                    <p><%= description %></p>
                                    <div class="food-footer">
                                        <span class="price">₹<%= price %></span>
                                        
                                        <% if (!inCart) { %>
                                            <form action="sides.jsp" method="POST" style="margin:0;">
                                                <input type="hidden" name="action" value="add">
                                                <input type="hidden" name="itemId" value="<%= itemId %>">
                                                <input type="hidden" name="name" value="<%= itemName.replace("\"", "&quot;") %>">
                                                <input type="hidden" name="price" value="<%= price %>">
                                                <input type="hidden" name="img" value="<%= imgUrl %>">
                                                <button type="submit" class="add-btn" <%= autoFocusAttr %>>Add +</button>
                                            </form>
                                        <% } else { %>
                                            <div class="leveler">
                                                <form action="sides.jsp" method="POST">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="itemId" value="<%= itemId %>">
                                                    <input type="hidden" name="change" value="-1">
                                                    <button type="submit" <%= autoFocusAttr %>>-</button>
                                                </form>
                                                <span><%= currentQty %></span>
                                                <form action="sides.jsp" method="POST">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="itemId" value="<%= itemId %>">
                                                    <input type="hidden" name="change" value="1">
                                                    <button type="submit" <%= autoFocusAttr %>>+</button>
                                                </form>
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                            </div>

                <%
                        } // End of if (charAt(0) == '6')
                    } // End of while
                %>

            <%
                 
                } catch(Exception e) {
                    out.println("<p style='color:red;'>Error loading menu: " + e.getMessage() + "</p>");
                } finally {
                    if(rs != null) try { rs.close(); } catch(SQLException e) {}
                    if(pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
                    if(conn != null) try { conn.close(); } catch(SQLException e) {}
                }
            %>

        </div>
    </div>

    <div id="floating-cart" class="floating-cart <%= totalItems > 0 ? "show" : "" %>">
        <div class="cart-info">
            <span style="font-size: 0.8rem; opacity: 0.8;"><%= totalItems %> <%= totalItems == 1 ? "Item" : "Items" %></span>
            <span class="cart-total-price">₹<%= String.format("%.2f", totalPrice) %></span>
        </div>
        <a href="cart.jsp" class="view-cart-btn">Finish Order <i class="fas fa-shopping-bag"></i></a>
    </div>

</body>
</html>