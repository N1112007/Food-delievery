<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // --- Calculate total items in the cart ---
    int totalCartItems = 0;
    HashMap<String, HashMap<String, String>> cart = (HashMap<String, HashMap<String, String>>) session.getAttribute("sessionCart");
    if (cart != null) {
        for (HashMap<String, String> item : cart.values()) {
            totalCartItems += Integer.parseInt(item.get("quantity"));
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FoodieDash | Discovery</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        /* --- CORE STYLES & OVERFLOW FIX --- */
        *, *::before, *::after { box-sizing: border-box; }
        
        :root {
            --primary: #6c5ce7;
            --secondary: #fd79a8;
            --dark: #2d3436;
            --light: #ffffff;
            --bg: #f9f9fb;
            --dominos-blue: #005A9C;
            --dominos-orange: #E35205;
        }
        
        html, body {
            margin: 0; padding: 0; width: 100%; max-width: 100%;
            overflow-x: hidden; background-color: var(--light);
            font-family: 'Poppins', sans-serif;
        }

        .page-wrapper { min-height: 100vh; width: 100%; max-width: 100%; overflow-x: hidden; position: relative; padding-bottom: 100px; }
        
        /* --- NAVBAR --- */
        .navbar { background: var(--light); padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; position: sticky; top: 0; z-index: 1000; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .nav-left { display: flex; align-items: center; gap: 15px; }
        .menu-btn { font-size: 22px; cursor: pointer; color: var(--dark); margin: 0; padding: 0; }
        .logo { font-weight: 800; font-size: 1.4rem; color: var(--primary); text-decoration: none; letter-spacing: -0.5px; }
        .nav-right { display: flex; align-items: center; gap: 20px; }
        .cart-icon { position: relative; color: var(--dark); font-size: 1.4rem; text-decoration: none; transition: transform 0.3s ease, color 0.3s ease; }
        .cart-icon:hover { transform: scale(1.1); color: var(--primary); }
        .cart-badge { position: absolute; top: -6px; right: -8px; background-color: var(--secondary); color: white; font-size: 0.65rem; font-weight: 700; height: 18px; width: 18px; display: flex; justify-content: center; align-items: center; border-radius: 50%; border: 2px solid var(--light); box-shadow: 0 2px 5px rgba(253, 121, 168, 0.4); }
        .profile-avatar { width: 42px; height: 42px; border-radius: 50%; background: linear-gradient(135deg, var(--primary), var(--secondary)); display: flex; justify-content: center; align-items: center; color: white; font-weight: 700; font-size: 1.2rem; box-shadow: 0 4px 12px rgba(253, 121, 168, 0.4); cursor: pointer; transition: transform 0.3s ease, box-shadow 0.3s ease; text-decoration: none; border: 2px solid white; }
        .profile-avatar:hover { transform: scale(1.1); box-shadow: 0 6px 15px rgba(108, 92, 231, 0.5); }

        /* --- PURE CSS SIDEBAR & DROPDOWN --- */
        #sidebar-toggle, #dropdown-toggle { display: none; }
        .sidebar { height: 100%; width: 0; position: fixed; z-index: 2000; top: 0; left: 0; background-color: var(--light); overflow-x: hidden; transition: 0.4s; padding-top: 60px; box-shadow: 2px 0 15px rgba(0,0,0,0.1); }
        .overlay { display: none; position: fixed; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1500; top: 0; left: 0; cursor: pointer; }
        #sidebar-toggle:checked ~ .sidebar { width: 300px; }
        #sidebar-toggle:checked ~ .overlay { display: block; }
        .sidebar a, .dropdown-btn { padding: 15px 30px; text-decoration: none; font-size: 1.1rem; color: var(--dark); display: block; transition: 0.3s; border-bottom: 1px solid #f1f1f1; background: none; border: none; width: 100%; text-align: left; cursor: pointer; font-family: 'Poppins', sans-serif;}
        .sidebar a i, .dropdown-btn i:first-child { margin-right: 15px; color: var(--primary); width: 25px; }
        .sidebar a:hover, .dropdown-btn:hover { background-color: #f9f9fb; color: var(--primary); }
        .close-btn { position: absolute; top: 10px; right: 20px; font-size: 30px; cursor: pointer; border: none; background: transparent; color: var(--dark); }
        .dropdown-container { display: none; background-color: #f9f9fb; border-left: 3px solid var(--primary); }
        .dropdown-container a { padding: 12px 30px 12px 50px; font-size: 0.95rem; border-bottom: 1px solid #eaeaea; }
        .dropdown-container a i { color: var(--secondary); font-size: 0.9rem; }
        #dropdown-toggle:checked ~ .dropdown-container { display: block; }

        /* --- STANDARD HORIZONTAL SCROLLS (For Offers & Craving) --- */
        .section-header { font-size: 1.2rem; font-weight: 700; color: var(--dark); padding: 25px 20px 15px 20px; margin: 0; }
        
        .h-scroll { display: flex; overflow-x: auto; gap: 15px; padding: 0 20px 10px 20px; scrollbar-width: none; scroll-snap-type: x mandatory; }
        .h-scroll::-webkit-scrollbar { display: none; }

        .offer-card { flex: 1; min-width: 280px; padding: 15px 20px; border-radius: 12px; color: white; display: flex; flex-direction: column; justify-content: center; scroll-snap-align: start; box-shadow: 0 4px 10px rgba(0,0,0,0.1); position: relative; overflow: hidden; }
        .offer-blue { background: var(--dominos-blue); }
        .offer-orange { background: var(--dominos-orange); }
        .offer-card h3 { margin: 0 0 5px 0; font-size: 1.1rem; display: flex; align-items: center; gap: 8px; }
        .offer-card p { margin: 0; font-size: 0.75rem; opacity: 0.9; }
        .offer-btn { position: absolute; right: 15px; top: 50%; transform: translateY(-50%); background: transparent; border: 1px solid white; color: white; padding: 5px 15px; border-radius: 20px; font-weight: 600; cursor: pointer; transition: 0.3s; }
        .offer-btn:hover { background: white; color: var(--dark); }

        .craving-item { flex: 1; display: flex; flex-direction: column; align-items: center; text-decoration: none; scroll-snap-align: start; min-width: 110px; max-width: 150px; cursor: pointer; }
        .craving-img { width: 105px; height: 105px; border-radius: 50%; background-size: cover; background-position: center; box-shadow: 0 4px 8px rgba(0,0,0,0.1); border: 3px solid transparent; transition: all 0.3s ease; }
        .craving-item:hover .craving-img { border-color: var(--secondary); transform: scale(1.05); box-shadow: 0 8px 15px rgba(253, 121, 168, 0.3); }
        .craving-text { font-size: 0.85rem; font-weight: 600; color: var(--dark); margin-top: 8px; text-align: center; line-height: 1.2; }

        /* --- THE PROFESSIONAL "PEEKING" BANNER CAROUSEL --- */
        .banner-container {
            display: flex;
            overflow-x: auto;
            gap: 15px; /* Space between banners */
            padding: 10px 20px 20px 20px;
            scroll-snap-type: x mandatory;
            scroll-behavior: smooth;
            scrollbar-width: none; /* Hides scrollbar on Firefox */
        }
        .banner-container::-webkit-scrollbar { display: none; } /* Hides scrollbar on Chrome/Safari */

        .promo-banner {
            /* 85% width means the next image is visible on the edge! */
            flex: 0 0 85%; 
            max-width: 400px; 
            height: 180px;
            border-radius: 16px;
            background-size: cover;
            background-position: center;
            scroll-snap-align: center; /* Snaps the banner perfectly into the middle */
            box-shadow: 0 6px 15px rgba(0,0,0,0.12);
        }
    </style>
</head>
<body>

    <input type="checkbox" id="sidebar-toggle">
    <label for="sidebar-toggle" class="overlay"></label>

    <div class="sidebar">
        <label for="sidebar-toggle" class="close-btn">&times;</label>
        
        <a href="CoustmerDashbord.jsp"><i class="fas fa-home"></i> Home</a>
        <a href="menu.jsp"><i class="fas fa-bars"></i> Menu</a>
        <a href="track.jsp"><i class="fas fa-map-marker-alt"></i> Track Order</a>
        <a href="OrderHistory.jsp"><i class="fas fa-history"></i> Order History</a>
        
        <div class="dropdown">
            <input type="checkbox" id="dropdown-toggle">
            <label for="dropdown-toggle" class="dropdown-btn">
                <i class="fas fa-headset"></i> Contact Us 
                <i class="fas fa-chevron-down" style="float: right; margin-right: 0; font-size: 0.9em; margin-top: 4px;"></i>
            </label>
            <div class="dropdown-container">
                <a href="tel:8050480504"><i class="fas fa-phone-alt"></i> 80504 80504</a>
                <a href="tel:121224121224"><i class="fas fa-phone-alt"></i> 121224 121224</a>
               <a href="mailto:Help@gmail.com"><i class="fas fa-envelope"></i> Help@gmail.com</a>
            </div>
        </div>

        <a href="logout.jsp" style="color: #e74c3c; margin-top: auto; border-top: 1px solid #f1f1f1;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="page-wrapper">
    
        <nav class="navbar">
            <div class="nav-left">
                <label for="sidebar-toggle" class="menu-btn"><i class="fas fa-bars"></i></label>
                <a href="menu.jsp" class="logo">FoodieDash</a>
            </div>
            <div class="nav-right">
                <a href="cart.jsp" class="cart-icon" title="View Cart">
                    <i class="fas fa-shopping-cart"></i>
                    <% if (totalCartItems > 0) { %>
                        <span class="cart-badge"><%= totalCartItems %></span>
                    <% } %>
                </a>
                <a href="profile.jsp" class="profile-avatar" title="Go to Profile">U</a>
            </div>
        </nav>

        <div class="section-header">Offers for you</div>
        <div class="h-scroll">
            <div class="offer-card offer-blue">
                <h3><i class="fas fa-certificate"></i> Get ₹100 Off</h3>
                <p>Up to ₹100 Off on orders worth ₹249 or more.</p>
                <button class="offer-btn">View</button>
            </div>
            <div class="offer-card offer-orange">
                <h3><i class="fas fa-certificate"></i> Get ₹125 Off</h3>
                <p>Up to ₹125 Off on orders worth ₹699 or more.</p>
                <button class="offer-btn">View</button>
            </div>
        </div>

        <div class="section-header">What are you craving for?</div>
        <div class="h-scroll">
            <a href="burgers.jsp" class="craving-item">
                <div class="craving-img" style="background-image: url('https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=200&q=80');"></div>
                <div class="craving-text">Burgers &<br>Sandwiches</div>
            </a>
            <a href="greens.jsp" class="craving-item">
                <div class="craving-img" style="background-image: url('https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=200&q=80');"></div>
                <div class="craving-text">Fresh Greens<br>& Bowls</div>
            </a>
            <a href="pasta.jsp" class="craving-item">
                <div class="craving-img" style="background-image: url('https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?auto=format&fit=crop&w=200&q=80');"></div>
                <div class="craving-text">Pasta &<br>Main Entrees</div>
            </a>
            <a href="pizza.jsp" class="craving-item">
                <div class="craving-img" style="background-image: url('https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=200&q=80');"></div>
                <div class="craving-text">Artisan Pizzas<br>(12-inch)</div>
            </a>
            <a href="sides.jsp" class="craving-item">
                <div class="craving-img" style="background-image: url('https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=200&q=80');"></div>
                <div class="craving-text">Sides &<br>Shareables</div>
            </a>
            <a href="desserts.jsp" class="craving-item">
                <div class="craving-img" style="background-image: url('https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=200&q=80');"></div>
                <div class="craving-text">Desserts<br>& Shakes</div>
            </a>
            <a href="beverages.jsp" class="craving-item">
                <div class="craving-img" style="background-image: url('https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=200&q=80');"></div>
                <div class="craving-text">Beverages<br>& Drinks</div>
            </a>
        </div>

        <div class="section-header">What's New</div>
        
        <div class="banner-container">
            <%
                Connection connBanner = null;
                PreparedStatement pstmtBanner = null;
                ResultSet rsBanner = null;
                boolean hasBanners = false;

                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    connBanner = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");
                    pstmtBanner = connBanner.prepareStatement("SELECT IMAGE_URL FROM BANNER ORDER BY ID DESC");
                    rsBanner = pstmtBanner.executeQuery();

                    while(rsBanner.next()) {
                        hasBanners = true;
            %>
                        <div class="promo-banner" style="background-image: url('<%= rsBanner.getString("IMAGE_URL") %>');"></div>
            <%
                    }
                    
                    if (!hasBanners) {
            %>
                        <div class="promo-banner" style="background-image: url('https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?auto=format&fit=crop&w=600&q=80');"></div>
            <%
                    }
                } catch (Exception e) {
            %>
                    <div class="promo-banner" style="background-image: url('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=600&q=80');"></div>
            <%
                } finally {
                    if (rsBanner != null) try { rsBanner.close(); } catch (SQLException e) {}
                    if (pstmtBanner != null) try { pstmtBanner.close(); } catch (SQLException e) {}
                    if (connBanner != null) try { connBanner.close(); } catch (SQLException e) {}
                }
            %>
        </div>

    </div> 

</body>
</html>