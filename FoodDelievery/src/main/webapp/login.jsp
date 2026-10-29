<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login | FoodieDash</title>
<style>
    /* Consistent UI styling across all pages */
    body {
        font-family: 'Poppins', sans-serif;
        margin: 0;
        height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #fd79a8);
        background-size: 400% 400%;
        animation: gradientBG 15s ease infinite;
        overflow: hidden;
    }

    @keyframes gradientBG {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    .login-card {
        background: rgba(255, 255, 255, 0.95);
        padding: 40px;
        border-radius: 24px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        width: 90%;
        max-width: 400px;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    .login-card h2 {
        text-align: center;
        color: #2d3436;
        margin-bottom: 5px;
        font-size: 1.8rem;
        font-weight: 800;
    }

    .login-card p {
        text-align: center;
        color: #636e72;
        margin-bottom: 25px;
    }

    /* --- NEW: Added Error Message Styling to match your UI --- */
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

    input[type="email"],
    input[type="password"] {
        width: 100%;
        padding: 14px;
        border: 2px solid #f1f2f6;
        border-radius: 12px;
        box-sizing: border-box;
        font-size: 1rem;
        background: #f9f9fb;
    }

    input:focus {
        outline: none;
        border-color: #6c5ce7;
        background-color: #fff;
    }

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
        transition: transform 0.2s;
    }

    .btn-submit:hover {
        transform: translateY(-2px);
    }

    .footer-link {
        text-align: center;
        margin-top: 20px;
        font-size: 0.9rem;
        color: #636e72;
    }

    .footer-link a {
        color: #6c5ce7;
        text-decoration: none;
        font-weight: 700;
    }
</style>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
</head>
<body>

<div class="login-card">
    <h2>Welcome Back!</h2>
    <p>Please enter your details.</p>

    <%
        String error = "";

        // Only run the database check if the user clicked the Submit button
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");

                String sql = "SELECT * FROM CUSTOMER WHERE EMAIL=? AND PASSWORD=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, email);
                pstmt.setString(2, password);
                
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // 1. SAVE TO SESSION SO PROFILE.JSP WORKS!
                    session.setAttribute("userEmail", email);
                    
                    // 2. REDIRECT TO HOME/MENU
                    response.sendRedirect("CoustmerDashbord.jsp");
                    return; 
                } else {
                    error = "Invalid Email or Password.";
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

    <form action="login.jsp" method="post">
        <div class="input-group">
            <label>Email Address</label>
            <input type="email" name="email" placeholder="alex@mail.com" required>
        </div>

        <div class="input-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="••••••••" required>
        </div>

        <button type="submit" class="btn-submit">Login</button>
    </form>

    <div class="footer-link">
        New here? <a href="register.jsp">Create an account</a>
    </div>
</div>

</body>
</html>