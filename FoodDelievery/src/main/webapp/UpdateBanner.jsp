<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Banners | Hotel Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
    
    <style>
        :root { --dark: #2d3436; --theme: #6c5ce7; --theme-accent: #a29bfe; --success: #00b894; --danger: #ff7675; --light: #f8fafc; }
        body { font-family: 'Poppins', sans-serif; margin: 0; background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #ff7675); background-size: 400% 400%; animation: gradientBG 15s ease infinite; min-height: 100vh; padding: 40px 20px; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }

        .container { width: 100%; max-width: 800px; }
        
        .top-bar { display: flex; justify-content: flex-start; margin-bottom: 20px; }
        .back-link { text-decoration: none; color: white; background: rgba(255, 255, 255, 0.2); padding: 10px 20px; border-radius: 12px; font-weight: 700; transition: 0.2s; display: flex; align-items: center; gap: 8px; backdrop-filter: blur(5px); border: 1px solid rgba(255,255,255,0.3); }
        .back-link:hover { background: white; color: var(--theme); }

        /* --- ADD BANNER CARD --- */
        .add-card { background: rgba(255, 255, 255, 0.95); padding: 30px; border-radius: 24px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.3); margin-bottom: 30px; }
        .add-card h2 { margin: 0 0 5px 0; color: var(--dark); font-weight: 800; font-size: 1.5rem; display: flex; align-items: center; gap: 10px; }
        .add-card p { margin: 0 0 20px 0; color: #636e72; font-size: 0.9rem; }

        .input-group { display: flex; gap: 15px; }
        input[type="url"] { flex: 1; padding: 15px; border: 2px solid #e2e8f0; border-radius: 12px; font-family: 'Poppins', sans-serif; font-size: 1rem; transition: 0.3s; background: var(--light); }
        input[type="url"]:focus { outline: none; border-color: var(--theme); background: white; box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.1); }
        
        .btn-add { padding: 0 25px; background: var(--theme); color: white; border: none; border-radius: 12px; font-size: 1rem; font-weight: 700; cursor: pointer; transition: 0.2s; white-space: nowrap; }
        .btn-add:hover { background: #5a4bcf; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(108, 92, 231, 0.3); }

        /* --- ACTIVE BANNERS GRID --- */
        .banners-header { color: white; margin: 0 0 15px 10px; font-weight: 800; text-shadow: 0 2px 5px rgba(0,0,0,0.3); }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        
        .banner-item { background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 20px rgba(0,0,0,0.15); position: relative; transition: 0.3s; }
        .banner-item:hover { transform: translateY(-5px); box-shadow: 0 15px 25px rgba(0,0,0,0.25); }
        
        .banner-img { width: 100%; height: 150px; object-fit: cover; display: block; background: #e2e8f0; }
        
        .banner-actions { padding: 15px; display: flex; justify-content: space-between; align-items: center; background: white; }
        .banner-id { font-weight: 700; color: var(--text-muted); font-size: 0.9rem; }
        
        .btn-remove { background: rgba(255, 118, 117, 0.1); color: var(--danger); border: none; padding: 8px 15px; border-radius: 8px; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: 'Poppins'; }
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

                // --- HANDLE ACTIONS (ADD OR REMOVE) ---
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String action = request.getParameter("action");

                    // 1. ADD BANNER
                    if ("add".equals(action)) {
                        String newBannerUrl = request.getParameter("bannerUrl");
                        if (newBannerUrl != null && !newBannerUrl.trim().isEmpty()) {
                            
                            // Find next available ID
                            int nextId = 1;
                            pstmt = conn.prepareStatement("SELECT NVL(MAX(ID), 0) + 1 FROM BANNER");
                            rs = pstmt.executeQuery();
                            if(rs.next()) nextId = rs.getInt(1);
                            rs.close(); pstmt.close();

                            // Insert new banner
                            pstmt = conn.prepareStatement("INSERT INTO BANNER (ID, IMAGE_URL) VALUES (?, ?)");
                            pstmt.setInt(1, nextId);
                            pstmt.setString(2, newBannerUrl);
                            pstmt.executeUpdate();
                            pstmt.close();

                            message = "New banner added successfully!";
                            msgType = "msg-success";
                        }
                    }
                    
                    // 2. REMOVE BANNER
                    else if ("remove".equals(action)) {
                        String removeId = request.getParameter("bannerId");
                        if (removeId != null) {
                            pstmt = conn.prepareStatement("DELETE FROM BANNER WHERE ID = ?");
                            pstmt.setInt(1, Integer.parseInt(removeId));
                            pstmt.executeUpdate();
                            pstmt.close();

                            message = "Banner removed successfully.";
                            msgType = "msg-success";
                        }
                    }
                }
        %>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= msgType %>"><%= message %></div>
        <% } %>

        <div class="add-card">
            <h2><i class="fas fa-plus-circle"></i> Add New Banner</h2>
            <p>Paste an image link below to add a new advertisement to the customer app.</p>
            <form method="POST">
                <input type="hidden" name="action" value="add">
                <div class="input-group">
                    <input type="url" name="bannerUrl" required placeholder="https://example.com/festival-offer.jpg">
                    <button type="submit" class="btn-add">Add Banner</button>
                </div>
            </form>
        </div>

        <h3 class="banners-header"><i class="fas fa-images"></i> Live Banners on App</h3>
        
        <div class="grid">
            <%
                // Fetch all banners currently in the database
                String fetchSql = "SELECT ID, IMAGE_URL FROM BANNER ORDER BY ID DESC";
                pstmt = conn.prepareStatement(fetchSql);
                rs = pstmt.executeQuery();
                boolean hasBanners = false;

                while(rs.next()) {
                    hasBanners = true;
                    int id = rs.getInt("ID");
                    String imgUrl = rs.getString("IMAGE_URL");
            %>
            
            <div class="banner-item">
                <img src="<%= imgUrl %>" class="banner-img" onerror="this.src='https://via.placeholder.com/400x200?text=Image+Not+Found'">
                <div class="banner-actions">
                    <span class="banner-id">ID: <%= id %></span>
                    
                    <form method="POST" style="margin: 0;" onsubmit="return confirm('Are you sure you want to remove this banner?');">
                        <input type="hidden" name="action" value="remove">
                        <input type="hidden" name="bannerId" value="<%= id %>">
                        <button type="submit" class="btn-remove"><i class="fas fa-trash-alt"></i> Remove</button>
                    </form>
                </div>
            </div>

            <%  } 
                if (!hasBanners) { 
            %>
                <div style="grid-column: 1 / -1; background: rgba(255,255,255,0.9); padding: 30px; border-radius: 16px; text-align: center; color: var(--text-muted);">
                    <i class="fas fa-image" style="font-size: 3rem; color: #cbd5e1; margin-bottom: 10px;"></i>
                    <p style="margin: 0; font-weight: 600;">No banners found. Add one above to show it to your customers!</p>
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