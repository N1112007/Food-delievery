<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. Session Check
    String sessionRiderName = (String) session.getAttribute("riderName");
    if (sessionRiderName == null || sessionRiderName.trim().isEmpty()) {
        response.sendRedirect("login1.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String message = "";
    String msgType = "";

    // Variables to hold current data
    int dbRiderId = 0;
    String dbName = "", dbPhone = "", dbVehicle = "", dbPassword = "", dbStatus = "";

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

        // ==========================================
        // 2. PROCESS BUTTON CLICKS (POST REQUESTS)
        // ==========================================
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");

            // --- ACTION 1: GO OFFLINE ---
            if ("offline".equals(action)) {
                try {
                    // Update status in DB
                    String sql = "UPDATE riders SET CURRENT_STATUS = 'offline' WHERE RIDER_NAME = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, sessionRiderName);
                    pstmt.executeUpdate();
                    pstmt.close();

                    // Clear session data
                    session.invalidate();

                    // Redirect and stop execution
                    response.sendRedirect("login1.jsp");
                    return; 
                } catch (Exception e) {
                    // If DB fails, we still want to log out for safety
                    session.invalidate();
                    response.sendRedirect("login1.jsp");
                    return;
                }
            }
            
            // --- ACTION 2: DELETE ACCOUNT ---
            else if ("delete".equals(action)) {
                // First: Unlink orders from this rider so we don't delete restaurant history
                String unlinkSql = "UPDATE orders SET RIDER_ID = NULL WHERE RIDER_ID = (SELECT RIDER_ID FROM riders WHERE RIDER_NAME = ?)";
                pstmt = conn.prepareStatement(unlinkSql);
                pstmt.setString(1, sessionRiderName);
                pstmt.executeUpdate();
                pstmt.close();

                // Second: Delete the rider from the riders table
                String deleteSql = "DELETE FROM riders WHERE RIDER_NAME = ?";
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setString(1, sessionRiderName);
                pstmt.executeUpdate();
                pstmt.close();

                session.invalidate();
                response.sendRedirect("login1.jsp");
                return; // Stop running code
            }
            
            // --- ACTION 3: UPDATE PROFILE ---
            else if ("update".equals(action)) {
                String newName = request.getParameter("riderName");
                String newVehicle = request.getParameter("vehicleNo");
                String newPassword = request.getParameter("password");

                // Note: PHONE_NO is NOT in this query because it should not be changed!
                String updateSql = "UPDATE riders SET RIDER_NAME = ?, VEHICLE_NO = ?, PASSWORD = ? WHERE RIDER_NAME = ?";
                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, newName);
                pstmt.setString(2, newVehicle);
                pstmt.setString(3, newPassword);
                pstmt.setString(4, sessionRiderName);

                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    message = "Profile updated successfully!";
                    msgType = "msg-success";
                    // Update session variable in case they changed their name
                    session.setAttribute("riderName", newName);
                    sessionRiderName = newName;
                } else {
                    message = "Failed to update profile.";
                    msgType = "msg-error";
                }
                pstmt.close();
            }
        }

        // ==========================================
        // 3. FETCH RIDER DATA FOR THE FORM
        // ==========================================
        String fetchSql = "SELECT * FROM riders WHERE RIDER_NAME = ?";
        pstmt = conn.prepareStatement(fetchSql);
        pstmt.setString(1, sessionRiderName);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            dbRiderId = rs.getInt("RIDER_ID");
            dbName = rs.getString("RIDER_NAME");
            dbPhone = rs.getString("PHONE_NO");
            dbVehicle = rs.getString("VEHICLE_NO");
            dbPassword = rs.getString("PASSWORD");
            dbStatus = rs.getString("CURRENT_STATUS");
            
            if(dbStatus == null) dbStatus = "offline";
        }

    } catch (Exception e) {
        message = "Database Error: " + e.getMessage();
        msgType = "msg-error";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rider Profile | FoodieDash</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        body { font-family: 'Poppins', sans-serif; margin: 0; min-height: 100vh; display: flex; justify-content: center; align-items: center; background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #00b894); background-size: 400% 400%; animation: gradientBG 15s ease infinite; padding: 20px; box-sizing: border-box; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }

        .profile-card { background: rgba(255, 255, 255, 0.95); padding: 40px; border-radius: 24px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); width: 100%; max-width: 500px; backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.3); }
        
        .top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .back-link, .btn-offline { text-decoration: none; font-family: 'Poppins', sans-serif; font-weight: 700; font-size: 0.9rem; padding: 8px 14px; border-radius: 10px; cursor: pointer; border: none; display: flex; align-items: center; gap: 6px; transition: 0.2s; }
        .back-link { color: #6c5ce7; background: rgba(108, 92, 231, 0.1); }
        .back-link:hover { background: #6c5ce7; color: white; }
        .btn-offline { color: #ff4757; background: rgba(255, 71, 87, 0.1); }
        .btn-offline:hover { background: #ff4757; color: white; }

        .profile-header { text-align: center; margin-bottom: 25px; }
        .profile-header i { font-size: 4rem; color: #6c5ce7; margin-bottom: 10px; background: linear-gradient(135deg, #6c5ce7, #00b894); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .profile-header h2 { color: #2d3436; margin: 0; font-size: 1.8rem; font-weight: 800; }

        .input-group { margin-bottom: 18px; }
        label.input-label { display: block; font-size: 0.8rem; color: #2d3436; margin-bottom: 6px; font-weight: 700; text-transform: uppercase; }
        input { width: 100%; padding: 14px; border: 2px solid #f1f2f6; border-radius: 12px; box-sizing: border-box; font-size: 1rem; background: #f9f9fb; font-family: 'Poppins', sans-serif; transition: 0.3s; }
        input:focus { outline: none; border-color: #6c5ce7; background-color: #fff; }
        input[readonly] { background: #e2e8f0; color: #636e72; cursor: not-allowed; border-color: #e2e8f0; font-weight: bold; }

        .btn-submit { width: 100%; padding: 16px; background: linear-gradient(to right, #6c5ce7, #00b894); color: white; border: none; border-radius: 12px; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: 0.2s; margin-top: 10px; }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(108, 92, 231, 0.3); }

        /* Modified button to label for CSS hack */
        .btn-delete-trigger { display: block; text-align: center; box-sizing: border-box; width: 100%; padding: 16px; background: transparent; color: #ff4757; border: 2px solid #ff4757; border-radius: 12px; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: 0.2s; margin-top: 15px; font-family: 'Poppins', sans-serif; }
        .btn-delete-trigger:hover { background: rgba(255, 71, 87, 0.1); }

        .message { padding: 12px; border-radius: 12px; margin-bottom: 20px; font-size: 0.9rem; font-weight: 600; text-align: center; }
        .msg-success { background: rgba(46, 204, 113, 0.1); color: #27ae60; border: 1px solid rgba(46, 204, 113, 0.3); }
        .msg-error { background: rgba(255, 71, 87, 0.1); color: #ff4757; border: 1px solid rgba(255, 71, 87, 0.3); }

        /* --- PURE CSS MODAL POPUP --- */
        #deleteToggle { display: none; /* Hide the actual checkbox */ }
        
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.6); z-index: 1000; align-items: center; justify-content: center; backdrop-filter: blur(5px); }
        .modal-box { background: white; padding: 40px 30px; border-radius: 24px; text-align: center; max-width: 400px; width: 90%; transform: scale(0.8); opacity: 0; transition: 0.3s ease-out; }
        
        /* Logic to show the modal when the hidden checkbox is checked */
        #deleteToggle:checked ~ .modal-overlay { display: flex; }
        #deleteToggle:checked ~ .modal-overlay .modal-box { transform: scale(1); opacity: 1; }
        
        .modal-box i { font-size: 4rem; color: #ff4757; margin-bottom: 15px; }
        .modal-box h3 { margin: 0 0 10px 0; font-weight: 800; font-size: 1.6rem; color: #2d3436; }
        .modal-box p { color: #636e72; margin-bottom: 25px; line-height: 1.5; font-size: 0.95rem; }
        
        .modal-btns { display: flex; gap: 15px; }
        
        /* Modified cancel button to label */
        .btn-cancel { flex: 1; background: #e2e8f0; color: #2d3436; padding: 14px; border-radius: 12px; border: none; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: 'Poppins'; display: block; text-align: center; box-sizing: border-box; margin: 0; }
        .btn-cancel:hover { background: #cbd5e1; }
        
        .btn-confirm { width: 100%; background: #ff4757; color: white; padding: 14px; border-radius: 12px; border: none; font-weight: 700; cursor: pointer; transition: 0.2s; font-family: 'Poppins'; }
        .btn-confirm:hover { background: #ff6b81; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255, 71, 87, 0.3); }
    </style>
</head>
<body>

    <div class="profile-card">
        
        <div class="top-bar">
            <a href="RiderDashbord.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Dashboard</a>
            
            <form method="POST" action="RiderProfile.jsp" style="margin: 0;">
                <input type="hidden" name="action" value="offline">
                <button type="submit" class="btn-offline">Offline <i class="fas fa-power-off"></i></button>
            </form>
        </div>

        <div class="profile-header">
            <i class="fas fa-motorcycle"></i>
            <h2>Rider Profile</h2>
            <span style="display:inline-block; margin-top:5px; background:#e2e8f0; padding:2px 10px; border-radius:10px; font-size:0.75rem; font-weight:bold; color:#2d3436;">ID: #<%= dbRiderId %></span>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= msgType %>">
                <%= message %>
            </div>
        <% } %>

        <form method="POST" action="RiderProfile.jsp">
            <input type="hidden" name="action" value="update">
            
            <div class="input-group">
                <label class="input-label">Rider Name</label>
                <input type="text" name="riderName" value="<%= dbName %>" required maxlength="20">
            </div>

            <div class="input-group">
                <label class="input-label">Phone Number (Cannot be changed)</label>
                <input type="text" value="<%= dbPhone %>" readonly>
            </div>

            <div class="input-group">
                <label class="input-label">Vehicle Number</label>
                <input type="text" name="vehicleNo" value="<%= dbVehicle %>" maxlength="10" required>
            </div>

            <div class="input-group">
                <label class="input-label">Password</label>
                <input type="password" name="password" value="<%= dbPassword %>" required maxlength="10">
            </div>

            <div class="input-group">
                <label class="input-label">Current Status</label>
                <input type="text" value="<%= dbStatus.toUpperCase() %>" readonly>
            </div>

            <button type="submit" class="btn-submit">Save Changes</button>
        </form>

        <label for="deleteToggle" class="btn-delete-trigger"><i class="fas fa-user-slash"></i> Delete Account</label>
        
    </div>

    <input type="checkbox" id="deleteToggle">

    <div class="modal-overlay">
        <div class="modal-box">
            <i class="fas fa-exclamation-triangle"></i>
            <h3>Are you sure?</h3>
            <p>If you delete your account, your profile will be permanently erased from the system.</p>
            
            <div class="modal-btns">
                <label for="deleteToggle" class="btn-cancel">No, Cancel</label>
                
                <form method="POST" action="RiderProfile.jsp" style="flex: 1; margin: 0;">
                    <input type="hidden" name="action" value="delete">
                    <button type="submit" class="btn-confirm">Yes, Delete</button>
                </form>
            </div>
        </div>
    </div>

</body>
</html>