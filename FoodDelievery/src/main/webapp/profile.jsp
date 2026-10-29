<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | FoodieDash</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        /* --- ANIMATED GRADIENT BACKGROUND --- */
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #fd79a8);
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            padding: 20px;
            box-sizing: border-box;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        /* --- GLASSMORPHISM CARD --- */
        .profile-card {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 24px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 500px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            position: relative;
        }

        /* --- TOP NAVIGATION BAR --- */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .top-bar a {
            text-decoration: none;
            font-weight: 700;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: 10px;
            transition: 0.2s;
        }

        .back-link { color: #6c5ce7; background: rgba(108, 92, 231, 0.1); }
        .back-link:hover { background: #6c5ce7; color: white; }

        .logout-link { color: #ff4757; background: rgba(255, 71, 87, 0.1); }
        .logout-link:hover { background: #ff4757; color: white; }

        /* --- PROFILE HEADER --- */
        .profile-header { text-align: center; margin-bottom: 25px; }
        .profile-header i {
            font-size: 4rem; color: #6c5ce7; margin-bottom: 10px;
            background: linear-gradient(135deg, #6c5ce7, #fd79a8);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
        }
        .profile-header h2 { color: #2d3436; margin: 0; font-size: 1.8rem; font-weight: 800; }

        /* --- FORM STYLES --- */
        .input-group { margin-bottom: 18px; }
        label.input-label { display: block; font-size: 0.8rem; color: #2d3436; margin-bottom: 6px; font-weight: 700; text-transform: uppercase; }

        input[type="text"], input[type="email"], input[type="password"], textarea {
            width: 100%; padding: 14px; border: 2px solid #f1f2f6; border-radius: 12px; box-sizing: border-box;
            font-size: 1rem; background: #f9f9fb; font-family: 'Poppins', sans-serif; transition: 0.3s;
        }
        input:focus, textarea:focus { outline: none; border-color: #6c5ce7; background-color: #fff; }
        input[readonly] { background: #e2e8f0; color: #636e72; cursor: not-allowed; border-color: #e2e8f0; }

        /* --- BUTTONS & LABELS ACTING AS BUTTONS --- */
        .btn-submit {
            width: 100%; padding: 16px; background: linear-gradient(to right, #6c5ce7, #fd79a8);
            color: white; border: none; border-radius: 12px; font-size: 1.1rem; font-weight: 700; cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s; margin-top: 10px;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(108, 92, 231, 0.3); }

        .btn-delete-trigger {
            display: block; text-align: center; box-sizing: border-box;
            width: 100%; padding: 16px; background: transparent; color: #ff4757; border: 2px solid #ff4757;
            border-radius: 12px; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: 0.2s; margin-top: 15px;
            font-family: 'Poppins', sans-serif;
        }
        .btn-delete-trigger:hover { background: rgba(255, 71, 87, 0.1); }

        /* --- MESSAGES --- */
        .message { padding: 12px; border-radius: 12px; margin-bottom: 20px; font-size: 0.9rem; font-weight: 600; text-align: center; }
        .msg-success { background: rgba(46, 204, 113, 0.1); color: #27ae60; border: 1px solid rgba(46, 204, 113, 0.3); }
        .msg-error { background: rgba(255, 71, 87, 0.1); color: #ff4757; border: 1px solid rgba(255, 71, 87, 0.3); }

        /* --- PURE CSS MODAL POPUP --- */
        #deleteToggle { display: none; /* Hide the actual checkbox */ }
        
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.6); z-index: 1000; align-items: center; justify-content: center;
            backdrop-filter: blur(5px);
        }
        
        .modal-box {
            background: white; padding: 40px 30px; border-radius: 24px; text-align: center; max-width: 400px; width: 90%;
            box-shadow: 0 15px 30px rgba(0,0,0,0.3); transform: scale(0.8); opacity: 0; transition: 0.3s ease-out;
        }

        /* Logic to show the modal when the hidden checkbox is checked */
        #deleteToggle:checked ~ .modal-overlay { display: flex; }
        #deleteToggle:checked ~ .modal-overlay .modal-box { transform: scale(1); opacity: 1; }
        
        .modal-box i { font-size: 4rem; color: #ff4757; margin-bottom: 15px; }
        .modal-box h3 { color: #2d3436; margin: 0 0 10px 0; font-weight: 800; font-size: 1.6rem; }
        .modal-box p { color: #636e72; margin-bottom: 25px; line-height: 1.5; font-size: 0.95rem; }
        
        .modal-btns { display: flex; gap: 15px; }
        
        .btn-cancel { 
            flex: 1; background: #e2e8f0; color: #2d3436; padding: 14px; border-radius: 12px; 
            border: none; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: 'Poppins'; 
            display: block; text-align: center; box-sizing: border-box; margin: 0;
        }
        .btn-cancel:hover { background: #cbd5e1; }
        
        .btn-confirm { 
            width: 100%; background: #ff4757; color: white; padding: 14px; border-radius: 12px; 
            border: none; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: 'Poppins'; 
        }
        .btn-confirm:hover { background: #ff6b81; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255, 71, 87, 0.3); }
    </style>
</head>
<body>

    <%
        // 1. Check Session: Who is logged in?
        String loggedInEmail = (String) session.getAttribute("userEmail");
        
        if (loggedInEmail == null || loggedInEmail.trim().isEmpty()) {
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String message = "";
        String msgType = "";

        String dbName = "", dbPhone = "", dbAddress = "", dbPassword = "";

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

            // 2. Handle POST Requests (Update OR Delete)
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("action"); 
                
                // --- ACTION: DELETE ACCOUNT ---
                if ("delete".equals(action)) {
                    String delOrdersSql = "DELETE FROM orders WHERE CUSTOMER_EMAIL=?";
                    pstmt = conn.prepareStatement(delOrdersSql);
                    pstmt.setString(1, loggedInEmail);
                    pstmt.executeUpdate();
                    pstmt.close();
                    
                    String delCustSql = "DELETE FROM CUSTOMER WHERE EMAIL=?";
                    pstmt = conn.prepareStatement(delCustSql);
                    pstmt.setString(1, loggedInEmail);
                    pstmt.executeUpdate();
                    pstmt.close();
                    
                    session.invalidate();
                    response.sendRedirect("login.jsp");
                    return;
                } 
                // --- ACTION: UPDATE PROFILE ---
                else {
                    String newName = request.getParameter("name");
                    String newPhone = request.getParameter("phone");
                    String newAddress = request.getParameter("address");
                    String newPassword = request.getParameter("password");

                    String updateSql = "UPDATE CUSTOMER SET NAME=?, PHONE=?, ADDRESS=?, PASSWORD=? WHERE EMAIL=?";
                    pstmt = conn.prepareStatement(updateSql);
                    pstmt.setString(1, newName);
                    pstmt.setString(2, newPhone);
                    pstmt.setString(3, newAddress);
                    pstmt.setString(4, newPassword);
                    pstmt.setString(5, loggedInEmail); 

                    int rowsUpdated = pstmt.executeUpdate();
                    if (rowsUpdated > 0) {
                        message = "Profile updated successfully!";
                        msgType = "msg-success";
                    } else {
                        message = "Could not update profile. Please try again.";
                        msgType = "msg-error";
                    }
                    pstmt.close();
                }
            }

            // 3. Fetch Current Data to populate the form
            String selectSql = "SELECT * FROM CUSTOMER WHERE EMAIL=?";
            pstmt = conn.prepareStatement(selectSql);
            pstmt.setString(1, loggedInEmail);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                dbName = rs.getString("NAME");
                dbPhone = rs.getString("PHONE");
                dbAddress = rs.getString("ADDRESS");
                dbPassword = rs.getString("PASSWORD");
                
                if (dbPhone == null) dbPhone = "";
                if (dbAddress == null) dbAddress = "";
            }

        } catch (Exception e) {
            message = "Database Error: " + e.getMessage();
            msgType = "msg-error";
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    %>

    <div class="profile-card">
        
        <div class="top-bar">
            <a href="CoustmerDashbord.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back</a>
            <a href="logout.jsp" class="logout-link">Logout <i class="fas fa-sign-out-alt"></i></a>
        </div>

        <div class="profile-header">
            <i class="fas fa-user-circle"></i>
            <h2>My Profile</h2>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= msgType %>">
                <%= message %>
            </div>
        <% } %>

        <form method="POST" action="profile.jsp">
            <input type="hidden" name="action" value="update">
            
            <div class="input-group">
                <label class="input-label">Full Name</label>
                <input type="text" name="name" value="<%= dbName %>" required maxlength="20">
            </div>

            <div class="input-group">
                <label class="input-label">Email Address (Cannot be changed)</label>
                <input type="email" value="<%= loggedInEmail %>" readonly>
            </div>

            <div class="input-group">
                <label class="input-label">Phone Number</label>
                <input type="text" name="phone" value="<%= dbPhone %>" maxlength="10" placeholder="e.g., 9876543210">
            </div>

            <div class="input-group">
                <label class="input-label">Delivery Address</label>
                <textarea name="address" rows="3" placeholder="Enter your full delivery address"><%= dbAddress %></textarea>
            </div>

            <div class="input-group">
                <label class="input-label">Password</label>
                <input type="password" name="password" value="<%= dbPassword %>" required maxlength="10">
            </div>

            <button type="submit" class="btn-submit">Save Changes</button>
        </form>

        <label for="deleteToggle" class="btn-delete-trigger"><i class="fas fa-trash-alt"></i> Delete Account</label>
        
    </div>

    <input type="checkbox" id="deleteToggle">

    <div class="modal-overlay">
        <div class="modal-box">
            <i class="fas fa-exclamation-triangle"></i>
            <h3>Are you sure?</h3>
            <p>If you delete your account, you will lose your profile, your saved addresses, and your entire order history. This cannot be undone!</p>
            
            <div class="modal-btns">
                <label for="deleteToggle" class="btn-cancel">No, Keep It</label>
                
                <form method="POST" action="profile.jsp" style="flex: 1; margin: 0;">
                    <input type="hidden" name="action" value="delete">
                    <button type="submit" class="btn-confirm">Yes, Delete</button>
                </form>
            </div>
        </div>
    </div>

</body>
</html>