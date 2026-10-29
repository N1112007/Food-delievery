<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Logged Out | FoodieDash</title>
<style>
    /* Reuse core body styles for consistency */
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
    }

    @keyframes gradientBG {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    .logout-card {
        background: rgba(255, 255, 255, 0.95);
        padding: 50px 40px;
        border-radius: 24px;
        text-align: center;
        width: 90%;
        max-width: 400px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.2);
    }

    .icon-box {
        font-size: 3rem;
        margin-bottom: 20px;
    }

    h2 {
        color: #2d3436;
        margin-bottom: 10px;
        font-weight: 800;
    }

    p {
        color: #636e72;
        margin-bottom: 30px;
    }

    .btn-relogin {
        display: inline-block;
        padding: 14px 30px;
        background: #6c5ce7;
        color: white;
        text-decoration: none;
        border-radius: 12px;
        font-weight: 700;
        transition: all 0.3s ease;
    }

    .btn-relogin:hover {
        background: #fd79a8;
        transform: scale(1.05);
    }
</style>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;800&display=swap" rel="stylesheet">
</head>
<body>

<div class="logout-card">
    <div class="icon-box">👋</div>
    <h2>See you soon!</h2>
    <p>You have been successfully logged out of FoodieDash.</p>

    <a href="login.jsp" class="btn-relogin">Login Again</a>
</div>

</body>
</html>