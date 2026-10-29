<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*" %>

<%
    // ==========================================
    // 1. JAVA SESSION CART LOGIC
    // ==========================================
    
    HashMap<String, HashMap<String, String>> cart = (HashMap<String, HashMap<String, String>>) session.getAttribute("sessionCart");
    if (cart == null) {
        cart = new HashMap<>();
        session.setAttribute("sessionCart", cart);
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            // FIX 1: Added .trim() here to remove any trailing database spaces
            String itemId = request.getParameter("itemId").trim();
            
            if (cart.containsKey(itemId)) {
                HashMap<String, String> item = cart.get(itemId);
                int newQty = Integer.parseInt(item.get("quantity")) + 1;
                item.put("quantity", String.valueOf(newQty));
            } else {
                HashMap<String, String> newItem = new HashMap<>();
                newItem.put("name", request.getParameter("name"));
                newItem.put("price", request.getParameter("price"));
                newItem.put("img", request.getParameter("img"));
                newItem.put("quantity", "1");
                cart.put(itemId, newItem);
            }
        } 
        else if ("update".equals(action)) {
            String itemId = request.getParameter("itemId");
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
        // --- APPLY OR REMOVE COUPON VIA BUTTON CLICK ---
        else if ("coupon".equals(action)) {
            String code = request.getParameter("code");
            if(code != null && !code.trim().isEmpty()) {
                session.setAttribute("couponCode", code.toUpperCase().trim());
            } else {
                // If the code is empty, it means they clicked "Remove"
                session.removeAttribute("couponCode");
            }
        }
        
        response.sendRedirect("cart.jsp");
        return;
    }

    // ==========================================
    // 2. CALCULATE TOTALS & FETCH DB DATA
    // ==========================================
    double subtotal = 0;
    boolean hasItems = !cart.isEmpty();
    String couponCode = (String) session.getAttribute("couponCode");
    String couponMsg = "";
    String msgClass = "";
    double discountAmount = 0;
    double deliveryFee = 40.0;
    
    // Grab the logged-in user's email (Change "email" if your session variable is named differently, like "userEmail")
    String loggedInUserEmail = (String) session.getAttribute("userEmail");
    String userDeliveryAddress = "Address not found. Please update your profile.";
    
    StringBuilder quantStrBuilder = new StringBuilder();
    StringBuilder itemsStrBuilder = new StringBuilder();
    
    for (Map.Entry<String, HashMap<String, String>> entry : cart.entrySet()) {
        HashMap<String, String> item = entry.getValue();
        double price = Double.parseDouble(item.get("price"));
        int qty = Integer.parseInt(item.get("quantity"));
        subtotal += (price * qty);
        
        quantStrBuilder.append(qty).append("x, ");
        itemsStrBuilder.append(item.get("name")).append(", ");
    }
    
    // Lists to hold DB results
    ArrayList<HashMap<String, String>> allCoupons = new ArrayList<>();
    ArrayList<HashMap<String, String>> suggestedItems = new ArrayList<>();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");
        
        // ---------------------------------------------------------
        // --- FETCH USER ADDRESS ----------------------------------
        // ---------------------------------------------------------
        try {
            if (loggedInUserEmail != null && !loggedInUserEmail.isEmpty()) {
                // IMPORTANT: Ensure 'ADDRESS' and 'EMAIL' match your customer table columns!
                pstmt = conn.prepareStatement("SELECT ADDRESS FROM customer WHERE EMAIL = ?");
                pstmt.setString(1, loggedInUserEmail);
                rs = pstmt.executeQuery();
                if(rs.next()) {
                    userDeliveryAddress = rs.getString("ADDRESS");
                }
                rs.close(); pstmt.close();
            }
        } catch (Exception addrEx) {
            // Keep default "Address not found" message if column names mismatch
            System.out.println("Address DB Error: " + addrEx.getMessage()); 
        }

        // ---------------------------------------------------------
        // --- FETCH SUGGESTED ITEMS (ID starts with 6 or 7) -------
        // ---------------------------------------------------------
        try {
            pstmt = conn.prepareStatement("SELECT * FROM items WHERE PRODUCT_ID LIKE '6%' OR PRODUCT_ID LIKE '7%'");
            rs = pstmt.executeQuery();
            while(rs.next()) {
                HashMap<String, String> sItem = new HashMap<>();
                // FIX 2: Added .trim() here to clean the database ID before sending it to the HTML
                sItem.put("id", rs.getString("PRODUCT_ID").trim()); 
                sItem.put("name", rs.getString("ITEM_NAME")); 
                sItem.put("price", String.valueOf(rs.getDouble("PRICE")));
                sItem.put("img", rs.getString("ITEM_IMG")); 
                suggestedItems.add(sItem);
            }
            rs.close(); pstmt.close();
        } catch (Exception itemEx) {
            couponMsg = "Item DB Error: " + itemEx.getMessage();
            msgClass = "text-error";
        }

        // ---------------------------------------------------------
        // --- EXISTING: Fetch and verify coupons ------------------
        // ---------------------------------------------------------
        pstmt = conn.prepareStatement("SELECT * FROM COUPONS ORDER BY DISCOUNT_AMOUNT DESC");
        rs = pstmt.executeQuery();
        while(rs.next()) {
            HashMap<String, String> c = new HashMap<>();
            c.put("code", rs.getString("CODE"));
            c.put("discount", String.valueOf(rs.getDouble("DISCOUNT_AMOUNT")));
            c.put("min", String.valueOf(rs.getDouble("MIN_ORDER")));
            c.put("desc", rs.getString("DESCRIPTION"));
            allCoupons.add(c);
        }
        rs.close(); pstmt.close();

        if (couponCode != null && !couponCode.isEmpty() && subtotal > 0) {
            pstmt = conn.prepareStatement("SELECT DISCOUNT_AMOUNT, MIN_ORDER FROM COUPONS WHERE CODE = ?");
            pstmt.setString(1, couponCode);
            rs = pstmt.executeQuery();
            
            if(rs.next()) {
                double dbDiscount = rs.getDouble("DISCOUNT_AMOUNT");
                double dbMinOrder = rs.getDouble("MIN_ORDER");
                
                if(subtotal >= dbMinOrder) {
                    discountAmount = dbDiscount;
                    if (discountAmount > subtotal) discountAmount = subtotal; 
                    couponMsg = "Promo code applied! (-₹" + String.format("%.0f", discountAmount) + ")";
                    msgClass = "text-success";
                } else {
                    couponMsg = "Cart total fell below the minimum order (₹" + dbMinOrder + ") for " + couponCode;
                    msgClass = "text-error";
                    discountAmount = 0; 
                    session.removeAttribute("couponCode"); 
                }
            } else {
                couponMsg = "Promo code no longer valid.";
                msgClass = "text-error";
                session.removeAttribute("couponCode");
            }
        }
    } catch(Exception e) {
        couponMsg = "Critical Database Error: " + e.getMessage();
        msgClass = "text-error";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    
    double grandTotal = subtotal + deliveryFee - discountAmount;
    
    if (hasItems) {
        String finalQuant = quantStrBuilder.substring(0, quantStrBuilder.length() - 2);
        String finalItems = itemsStrBuilder.substring(0, itemsStrBuilder.length() - 2);
        session.setAttribute("checkoutTotal", String.valueOf(grandTotal));
        session.setAttribute("checkoutQuant", finalQuant);
        session.setAttribute("checkoutItems", finalItems);
        // Add the address to session so your checkout/processOrder page can grab it easily!
        session.setAttribute("checkoutAddress", userDeliveryAddress); 
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Your Cart | FoodieDash</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root { --dark: #2d3436; --light: #f9f9fb; --white: #ffffff; --text-muted: #636e72; --theme: #6c5ce7; --theme-gradient: linear-gradient(to right, #6c5ce7, #fd79a8); --success: #00b894; --danger: #ff4757; }
        body { font-family: 'Poppins', sans-serif; margin: 0; min-height: 100vh; background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #fd79a8); background-size: 400% 400%; animation: gradientBG 15s ease infinite; display: flex; flex-direction: column; align-items: center; padding: 20px; box-sizing: border-box; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }
        
        .page-header { width: 100%; max-width: 800px; display: flex; align-items: center; gap: 15px; margin-bottom: 20px; margin-top: 10px; }
        .back-btn { color: var(--white); font-size: 1.5rem; text-decoration: none; transition: 0.2s; }
        .page-title { margin: 0; font-size: 1.6rem; font-weight: 800; color: var(--white); }
        .cart-container { background: rgba(255, 255, 255, 0.95); padding: 30px; border-radius: 24px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); width: 100%; max-width: 800px; backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.3); box-sizing: border-box; }
        
        .cart-item { background: var(--white); padding: 15px; border-radius: 16px; display: flex; align-items: center; gap: 15px; margin-bottom: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #f1f2f6; }
        .cart-item-img { width: 80px; height: 80px; border-radius: 12px; background-size: cover; background-position: center; }
        .cart-item-details { flex-grow: 1; }
        .cart-item-details h4 { margin: 0 0 5px 0; font-size: 1.1rem; color: var(--dark); }
        .cart-item-details p { margin: 0; font-weight: 700; color: var(--theme); }
        .leveler { display: flex; align-items: center; justify-content: space-between; background: var(--light); border: 2px solid #f1f2f6; border-radius: 12px; overflow: hidden; height: 36px; width: 100px; }
        .leveler form { display: contents; } 
        .leveler button { background: transparent; color: var(--dark); border: none; width: 35px; height: 100%; font-size: 1.2rem; font-weight: 800; cursor: pointer; transition: 0.2s; }
        .leveler button:hover { background: #e2e8f0; }
        .leveler span { width: 30px; text-align: center; font-weight: 800; color: var(--dark); }
        
        /* --- SLIDER SHARED CSS --- */
        .slider-header { font-size: 1.1rem; font-weight: 800; color: var(--dark); margin: 30px 0 10px 0; }
        .horizontal-slider { display: flex; overflow-x: auto; gap: 15px; padding-bottom: 10px; scrollbar-width: none; }
        .horizontal-slider::-webkit-scrollbar { display: none; }
        
        /* --- NEW: SUGGESTED ITEMS CSS --- */
        .suggested-card { min-width: 160px; background: var(--white); border: 1px solid #dfe6e9; border-radius: 16px; padding: 15px; display: flex; flex-direction: column; gap: 10px; align-items: center; text-align: center; transition: 0.3s; box-shadow: 0 4px 10px rgba(0,0,0,0.02); }
        .suggested-card:hover { border-color: var(--theme); transform: translateY(-3px); }
        .suggested-img { width: 80px; height: 80px; border-radius: 50%; background-size: cover; background-position: center; border: 2px solid #f1f2f6; }
        .suggested-info h4 { margin: 0; font-size: 0.95rem; color: var(--dark); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 140px; }
        .suggested-info p { margin: 2px 0 0 0; color: var(--theme); font-weight: 700; font-size: 0.9rem; }
        .btn-add-suggested { background: rgba(108, 92, 231, 0.1); color: var(--theme); border: 1px solid var(--theme); padding: 6px 15px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; width: 100%; font-family: 'Poppins', sans-serif; font-size: 0.85rem;}
        .btn-add-suggested:hover { background: var(--theme); color: white; }

        /* --- COUPONS CSS --- */
        .coupon-card { min-width: 250px; background: var(--white); border: 2px dashed #dfe6e9; border-radius: 16px; padding: 15px; display: flex; justify-content: space-between; align-items: center; transition: 0.3s; }
        .coupon-card.applied { border-color: var(--success); background: rgba(0, 184, 148, 0.05); }
        .c-info h4 { margin: 0 0 4px 0; font-size: 1.1rem; color: var(--theme); font-weight: 800; letter-spacing: 1px; }
        .c-info p { margin: 0 0 6px 0; font-size: 0.8rem; color: var(--text-muted); line-height: 1.3; }
        .c-min { font-size: 0.75rem; font-weight: 700; color: var(--success); background: rgba(0, 184, 148, 0.1); padding: 3px 8px; border-radius: 6px; display: inline-block; }
        .c-min.locked { color: var(--danger); background: rgba(255, 71, 87, 0.1); }
        .btn-c { padding: 8px 15px; border-radius: 10px; font-weight: 700; font-size: 0.9rem; border: none; cursor: pointer; transition: 0.2s; font-family: 'Poppins', sans-serif;}
        .btn-apply { background: var(--dark); color: white; }
        .btn-apply:hover { background: black; }
        .btn-remove { background: rgba(255, 71, 87, 0.1); color: var(--danger); }
        .btn-remove:hover { background: var(--danger); color: white; }
        .btn-locked { background: #e2e8f0; color: #a0aec0; cursor: not-allowed; }

        /* --- NEW: DELIVERY ADDRESS CSS --- */
        .address-card { background: var(--white); padding: 20px; border-radius: 16px; margin-top: 25px; border: 1px solid #dfe6e9; display: flex; align-items: flex-start; gap: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .address-icon { background: rgba(108, 92, 231, 0.1); color: var(--theme); width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; flex-shrink: 0; }
        .address-details { flex-grow: 1; }
        .address-details h4 { margin: 0 0 5px 0; font-size: 1.1rem; color: var(--dark); font-weight: 800; }
        .address-details p { margin: 0; font-size: 0.9rem; color: var(--text-muted); line-height: 1.4; }
        .btn-change-address { background: transparent; color: var(--theme); border: none; font-weight: 700; cursor: pointer; text-decoration: underline; padding: 0; margin-top: 8px; font-family: 'Poppins', sans-serif; font-size: 0.85rem;}

        .summary-card { background: var(--light); padding: 25px; border-radius: 20px; margin-top: 20px; border: 1px solid #f1f2f6; }
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 15px; color: var(--text-muted); font-weight: 600; }
        .summary-total { display: flex; justify-content: space-between; font-weight: 800; font-size: 1.4rem; color: var(--dark); border-top: 2px dashed #dfe6e9; padding-top: 15px; margin-top: 10px; }
        
        #coupon-message { font-size: 0.9rem; margin-top: 0; margin-bottom: 20px; font-weight: 700; background: white; padding: 10px; border-radius: 10px; text-align: center; border: 1px solid transparent; }
        .text-success { color: var(--success); border-color: rgba(0, 184, 148, 0.3) !important; } 
        .text-error { color: var(--danger); border-color: rgba(255, 71, 87, 0.3) !important; }
        .discount-row { color: var(--success) !important; font-weight: 700; }
        
        .checkout-btn { width: 100%; background: var(--theme-gradient); color: white; border: none; padding: 16px; border-radius: 14px; font-size: 1.1rem; font-weight: 700; margin-top: 25px; cursor: pointer; text-decoration: none; display: block; text-align: center; box-shadow: 0 10px 20px rgba(108, 92, 231, 0.2); transition: 0.2s; }
        .checkout-btn:hover { transform: translateY(-2px); box-shadow: 0 12px 25px rgba(108, 92, 231, 0.3); }
        
        .empty-cart-msg { text-align: center; padding: 60px 20px; color: var(--text-muted); }
        .empty-cart-msg i { font-size: 5rem; color: #dfe6e9; margin-bottom: 20px; }
        .empty-cart-msg h2 { color: var(--dark); font-weight: 800; margin-bottom: 5px; }
    </style>
</head>
<body>

    <div class="page-header">
        <a href="CoustmerDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
        <h1 class="page-title">Shopping Cart</h1>
    </div>

    <div class="cart-container">
        
        <% if (hasItems) { %>
            
            <div id="cart-items-container">
                <% for (Map.Entry<String, HashMap<String, String>> entry : cart.entrySet()) {
                    String itemId = entry.getKey();
                    HashMap<String, String> item = entry.getValue();
                %>
                <div class="cart-item">
                    <div class="cart-item-img" style="background-image: url('<%= item.get("img") %>');"></div>
                    <div class="cart-item-details">
                        <h4><%= item.get("name") %></h4>
                        <p>₹<%= item.get("price") %></p>
                    </div>
                    <div class="leveler">
                        <form action="cart.jsp" method="POST">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="itemId" value="<%= itemId %>">
                            <input type="hidden" name="change" value="-1">
                            <button type="submit">-</button>
                        </form>
                        <span><%= item.get("quantity") %></span>
                        <form action="cart.jsp" method="POST">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="itemId" value="<%= itemId %>">
                            <input type="hidden" name="change" value="1">
                            <button type="submit">+</button>
                        </form>
                    </div>
                </div>
                <% } %>
            </div>

            <% if (!suggestedItems.isEmpty()) { %>
                <div class="slider-header"><i class="fas fa-star" style="color: #fdcb6e;"></i> Add Something Else?</div>
                <div class="horizontal-slider">
                    <% for(HashMap<String, String> sItem : suggestedItems) { %>
                        <div class="suggested-card">
                            <div class="suggested-img" style="background-image: url('<%= sItem.get("img") %>');"></div>
                            <div class="suggested-info">
                                <h4><%= sItem.get("name") %></h4>
                                <p>₹<%= sItem.get("price") %></p>
                            </div>
                            <form action="cart.jsp" method="POST" style="width: 100%; margin: 0;">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="itemId" value="<%= sItem.get("id") %>">
                                <input type="hidden" name="name" value="<%= sItem.get("name") %>">
                                <input type="hidden" name="price" value="<%= sItem.get("price") %>">
                                <input type="hidden" name="img" value="<%= sItem.get("img") %>">
                                <button type="submit" class="btn-add-suggested">+ Add to Cart</button>
                            </form>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <% if (!allCoupons.isEmpty()) { %>
                <div class="slider-header"><i class="fas fa-ticket-alt" style="color: var(--success);"></i> Available Offers</div>
                <div class="horizontal-slider">
                    <% 
                        for(HashMap<String, String> c : allCoupons) { 
                            String cCode = c.get("code");
                            double cMin = Double.parseDouble(c.get("min"));
                            boolean isApplied = cCode.equals(couponCode);
                            boolean meetsMinOrder = subtotal >= cMin;
                    %>
                        <div class="coupon-card <%= isApplied ? "applied" : "" %>">
                            <div class="c-info">
                                <h4><%= cCode %></h4>
                                <p><%= c.get("desc") %></p>
                                
                                <% if (meetsMinOrder) { %>
                                    <span class="c-min">Min Order: ₹<%= c.get("min") %></span>
                                <% } else { %>
                                    <span class="c-min locked">Add ₹<%= String.format("%.0f", cMin - subtotal) %> more</span>
                                <% } %>
                            </div>
                            
                            <div class="c-action">
                                <form action="cart.jsp" method="POST" style="margin:0;">
                                    <input type="hidden" name="action" value="coupon">
                                    <% if (isApplied) { %>
                                        <input type="hidden" name="code" value="">
                                        <button type="submit" class="btn-c btn-remove">Remove</button>
                                    <% } else if (meetsMinOrder) { %>
                                        <input type="hidden" name="code" value="<%= cCode %>">
                                        <button type="submit" class="btn-c btn-apply">Apply</button>
                                    <% } else { %>
                                        <button type="button" class="btn-c btn-locked" disabled>Locked</button>
                                    <% } %>
                                </form>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <div class="address-card">
                <div class="address-icon">
                    <i class="fas fa-map-marker-alt"></i>
                </div>
                <div class="address-details">
                    <h4>Delivering to:</h4>
                    <p><%= userDeliveryAddress %></p>
                    <button class="btn-change-address">Change Address</button>
                </div>
            </div>

            <div class="summary-card">
                
                <% if (!couponMsg.isEmpty()) { %>
                    <p id="coupon-message" class="<%= msgClass %>"><i class="fas <%= msgClass.equals("text-success") ? "fa-check-circle" : "fa-exclamation-circle" %>"></i> <%= couponMsg %></p>
                <% } %>

                <div class="summary-row"><span>Subtotal</span><span>₹<%= String.format("%.2f", subtotal) %></span></div>
                <div class="summary-row"><span>Delivery Fee</span><span>₹<%= String.format("%.2f", deliveryFee) %></span></div>
                
                <% if (discountAmount > 0) { %>
                    <div class="summary-row discount-row">
                        <span>Promo (<%= couponCode %>)</span>
                        <span>-₹<%= String.format("%.2f", discountAmount) %></span>
                    </div>
                <% } %>

                <div class="summary-total"><span>Total</span><span>₹<%= String.format("%.2f", grandTotal) %></span></div>
                
                <a href="processOrder.jsp" class="checkout-btn">Proceed to Checkout</a>
            </div>

        <% } else { %>
            <div class="empty-cart-msg">
                <i class="fas fa-shopping-basket"></i>
                <h2>Your cart is empty</h2>
                <p>Looks like you haven't added anything yet.</p>
                <a href="CoustmerDashbord.jsp" style="display:inline-block; margin-top:20px; color:var(--theme); text-decoration:none; font-weight:700;">Start Browsing <i class="fas fa-arrow-right"></i></a>
            </div>
        <% } %>

    </div>

</body>
</html>