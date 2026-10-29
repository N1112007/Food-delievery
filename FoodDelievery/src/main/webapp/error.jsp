<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Error | FoodieDash</title>
<style>
    /* 1. Shared Background Styles */
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
        padding: 20px;
        box-sizing: border-box;
    }

    @keyframes gradientBG {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    /* 2. Frosted Glass Card */
    .error-card {
        background: rgba(255, 255, 255, 0.95);
        padding: 50px 40px;
        border-radius: 24px;
        text-align: center;
        width: 100%;
        max-width: 400px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.3);
    }

    /* 3. Typography & Icons */
    .icon-box {
        font-size: 3.5rem;
        margin-bottom: 15px;
        /* A soft red color for the error icon */
        color: #ff7675; 
    }

    .error-card h2 {
        color: #2d3436;
        margin: 0 0 10px 0;
        font-weight: 800;
        font-size: 1.8rem;
    }

    .error-card p {
        color: #636e72;
        margin-bottom: 30px;
        font-size: 0.95rem;
        line-height: 1.5;
    }

    /* 4. Action Button */
    .btn-retry {
        display: block;
        width: 100%;
        padding: 16px;
        background: linear-gradient(to right, #6c5ce7, #fd79a8);
        color: white;
        text-decoration: none;
        border-radius: 12px;
        font-size: 1.1rem;
        font-weight: 700;
        transition: transform 0.2s, box-shadow 0.2s;
        box-sizing: border-box;
    }

    .btn-retry:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(108, 92, 231, 0.4);
    }

    /* 5. Footer Link */
    .footer-link {
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
</style>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
</head>
<body>

<div class="error-card">
    <div class="icon-box">⚠️</div>
    
    <h2>Oops! Login Failed</h2>
    <p>We couldn't find an account matching those credentials. Please check your email and password and try again.</p>

    <a href="login.jsp" class="btn-retry">Try Again</a>

    <div class="footer-link">
        Don't have an account? <a href="register.jsp">Sign up here</a>
    </div>
</div>

</body>
</html>