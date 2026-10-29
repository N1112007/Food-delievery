<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Rider Login | FoodieDash</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    /* 1. Dynamic Gradient Background (Consistent UI) */
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
    }

    @keyframes gradientBG {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    /* 2. Frosted Glass Card */
    .login-card {
        background: rgba(255, 255, 255, 0.95);
        padding: 40px;
        border-radius: 24px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        width: 100%;
        max-width: 420px;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .login-card h2 {
        text-align: center;
        color: #2d3436;
        margin-bottom: 5px;
        font-size: 1.8rem;
        font-weight: 800;
        letter-spacing: -0.5px;
    }

    .login-card p {
        text-align: center;
        color: #636e72;
        font-size: 0.95rem;
        margin-bottom: 25px;
    }

    /* --- NEW: Error Message Styling --- */
    .error-msg {
        background: rgba(255, 71, 87, 0.1);
        color: #ff4757;
        padding: 12px;
        border-radius: 12px;
        margin-bottom: 20px;
        font-size: 0.9rem;
        font-weight: 600;
        text-align: center;
        border: 1px solid rgba(255, 71, 87, 0.3);
    }

    /* 3. Form Styling */
    .input-group {
        margin-bottom: 18px;
    }

    label {
        display: block;
        font-size: 0.8rem;
        color: #2d3436;
        margin-bottom: 6px;
        font-weight: 700;
        text-transform: uppercase;
    }

    input {
        width: 100%;
        padding: 14px;
        border: 2px solid #f1f2f6;
        border-radius: 12px;
        box-sizing: border-box;
        font-size: 1rem;
        transition: all 0.3s ease;
        background: #f9f9fb;
        font-family: 'Poppins', sans-serif;
    }

    input:focus {
        outline: none;
        border-color: #6c5ce7;
        background-color: #fff;
        box-shadow: 0 0 12px rgba(108, 92, 231, 0.2);
    }

    /* 4. The Aesthetic Submit Button */
    .btn-submit {
        width: 100%;
        padding: 16px;
        background: linear-gradient(to right, #6c5ce7, #fd79a8);
        color: white;
        border: none;
        border-radius: 12px;
        font-size: 1.1rem;
        font-weight: 700;
        cursor: pointer;
        transition: transform 0.2s, box-shadow 0.2s;
        margin-top: 15px;
    }

    .btn-submit:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(108, 92, 231, 0.4);
    }

    .btn-submit:active {
        transform: translateY(0);
    }

    /* 5. Footer Link */
    .footer-link {
        text-align: center;
        margin-top: 25px;
        font-size: 0.9rem;
        color: #636e72;
    }

    .footer-link a {
        color: #6c5ce7;
        text-decoration: none;
        font-weight: 700;
    }

    .footer-link a:hover {
        color: #fd79a8;
    }

    .rider-badge {
        display: block;
        width: fit-content;
        margin: 0 auto 10px auto;
        background: #6c5ce7;
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.7rem;
        font-weight: 700;
        text-transform: uppercase;
    }
</style>
</head>
<body>

<div class="login-card">
    <span class="rider-badge"><i class="fas fa-motorcycle"></i> Rider Portal</span>
    <h2>Ready to Deliver?</h2>
    <p>Sign in to start your shift.</p>

    <%
        String error = "";

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String name = request.getParameter("name");
            String password = request.getParameter("password");

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

                // Check credentials in the riders table
                String sql = "SELECT * FROM riders WHERE RIDER_NAME=? AND PASSWORD=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name);
                pstmt.setString(2, password);
                
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // 1. SAVE TO SESSION SO RIDER PROFILE WORKS!
                    session.setAttribute("riderName", name);

                    // 2. SET RIDER STATUS TO ONLINE
                    PreparedStatement updatePs = conn.prepareStatement("UPDATE riders SET CURRENT_STATUS = 'online' WHERE RIDER_NAME = ?");
                    updatePs.setString(1, name);
                    updatePs.executeUpdate();
                    updatePs.close();
                    
                    // 3. REDIRECT TO RIDER DASHBOARD
                    // --- UPDATED THIS LINE ---
                    response.sendRedirect("RiderDashbord.jsp");
                    return; 
                } else {
                    error = "Invalid Rider Name or Password.";
                }
            } catch (Exception e) {
                error = "Database Error: " + e.getMessage();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }
    %>

    <%-- Display the error message if login fails --%>
    <% if (!error.isEmpty()) { %>
        <div class="error-msg"><%= error %></div>
    <% } %>

    <form action="login1.jsp" method="post">
        <div class="input-group">
            <label>Rider Name</label>
            <input type="text" name="name" placeholder="E.g. John Doe" required>
        </div>

        <div class="input-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="••••••••" required>
        </div>

        <button type="submit" class="btn-submit">Login as Rider</button>
    </form>

    <div class="footer-link">
        Not a rider? <a href="register1.jsp">Create an account</a>
    </div>
</div>

</body>
</html>