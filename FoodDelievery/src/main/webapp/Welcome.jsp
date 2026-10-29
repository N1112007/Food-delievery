<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome - Food Delivery</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;700;900&display=swap" rel="stylesheet">
    
    <style>
        /* Reset and Base Styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            
            /* --- YOUR ANIMATED GRADIENT BACKGROUND --- */
            background: linear-gradient(-45deg, #2d3436, #6c5ce7, #a29bfe, #fd79a8);
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            
            overflow: hidden; /* Prevents scrollbars while things slide in */
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .welcome-container {
            text-align: center;
        }

        /* --- Welcome Text Animation --- */
        .welcome-text {
            font-size: 4rem;
            color: white;
            font-weight: 900;
            text-shadow: 2px 4px 15px rgba(0,0,0,0.4); 
            /* Start invisible and higher up */
            opacity: 0; 
            transform: translateY(-50px);
            /* Animate in */
            animation: dropIn 1.2s cubic-bezier(0.25, 1, 0.5, 1) forwards;
        }

        .subtitle {
            font-size: 2rem;
            font-weight: 400;
            color: #f1f2f6; /* Off-white so it stands out against the shifting colors */
        }

        @keyframes dropIn {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* --- Button Layout --- */
        .button-group {
            margin-top: 50px;
            display: flex;
            flex-direction: column; /* Stacks the buttons vertically */
            gap: 20px; /* The gap between the buttons */
            align-items: center;
        }

        /* Base Button Styling */
        .btn {
            text-decoration: none;
            color: #6c5ce7; /* Matched the purple from your animated gradient */
            background: white;
            padding: 15px 40px;
            font-size: 1.2rem;
            font-weight: 700;
            border-radius: 50px; /* Perfect pill shape */
            width: 280px;
            text-align: center;
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            
            /* Start off-screen to the left for the animation */
            opacity: 0;
            transform: translateX(-150vw); 
        }

        /* Hover effect once the buttons are in place */
        .btn:hover {
            transform: scale(1.05); /* Slight pop when the mouse hovers */
            box-shadow: 0 15px 25px rgba(0,0,0,0.4); /* Deeper shadow on hover */
        }

        /* --- Button Slide-in Animations (Staggered) --- */
        .btn-customer {
            /* Starts 0.8s after page load */
            animation: slideInLeft 0.8s cubic-bezier(0.25, 1, 0.5, 1) 0.8s forwards; 
        }

        .btn-hotel {
            /* Starts 1.0s after page load */
            animation: slideInLeft 0.8s cubic-bezier(0.25, 1, 0.5, 1) 1.0s forwards;
        }

        .btn-rider {
            /* Starts 1.2s after page load */
            animation: slideInLeft 0.8s cubic-bezier(0.25, 1, 0.5, 1) 1.2s forwards;
        }

        @keyframes slideInLeft {
            0% {
                opacity: 0;
                transform: translateX(-100vw);
            }
            80% {
                transform: translateX(15px); /* A tiny overshoot for a realistic "bounce" */
            }
            100% {
                opacity: 1;
                transform: translateX(0); /* Final resting position */
            }
        }
    </style>
</head>
<body>
    <div class="welcome-container">
        <h1 class="welcome-text">Craving Something? <br><span class="subtitle">Let's get started.</span></h1>

        <div class="button-group">
            <a href="login.jsp" class="btn btn-customer">I am a Customer</a>
            <a href="login1.jsp" class="btn btn-hotel">I am a Rider</a>
            <a href="HotelDashbord.jsp" class="btn btn-rider">I am a Hotel</a>
        </div>
    </div>
</body>
</html>