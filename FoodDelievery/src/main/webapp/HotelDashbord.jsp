<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | FoodieDash</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        /* --- 1. CORE & THEME STYLES --- */
        :root {
            --dark: #2d3436;
            --light: #f9f9fb;
            --white: #ffffff;
            --text-muted: #636e72;
            --theme: #0984e3; 
            --theme-accent: #00cec9;
            --card-hover: rgba(9, 132, 227, 0.05);
        }
        body { font-family: 'Poppins', sans-serif; margin: 0; background-color: var(--light); padding-bottom: 50px; }

        /* --- 2. HEADER --- */
        .admin-header { 
            background: var(--dark); 
            padding: 25px 20px; 
            color: var(--white);
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.1); 
        }
        .header-title { margin: 0; font-size: 1.5rem; font-weight: 800; display: flex; align-items: center; gap: 10px; }
        .logout-btn { 
            background: rgba(255,255,255,0.1); 
            color: var(--white); 
            text-decoration: none; 
            padding: 8px 16px; 
            border-radius: 8px; 
            font-weight: 600; 
            transition: 0.2s; 
        }
        .logout-btn:hover { background: #e74c3c; } /* Red on hover for logout */

        /* --- 3. DASHBOARD GRID --- */
        .dashboard-container { padding: 40px 20px; max-width: 1000px; margin: auto; }
        .welcome-text { margin-bottom: 30px; color: var(--dark); }
        .welcome-text h2 { margin: 0 0 5px 0; font-size: 1.8rem; }
        .welcome-text p { margin: 0; color: var(--text-muted); }

        .dash-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); 
            gap: 25px; 
        }

        /* --- 4. ACTION CARDS --- */
        .dash-card { 
            background: var(--white); 
            border-radius: 20px; 
            padding: 30px 20px; 
            text-decoration: none; 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            text-align: center;
            box-shadow: 0 8px 20px rgba(0,0,0,0.04); 
            transition: all 0.3s ease; 
            border: 1px solid rgba(0,0,0,0.02); 
            position: relative;
            overflow: hidden;
        }
        
        .dash-card::before {
            content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 4px; background: var(--theme); transform: scaleX(0); transition: transform 0.3s ease; transform-origin: left;
        }

        .dash-card:hover { 
            transform: translateY(-5px); 
            box-shadow: 0 15px 30px rgba(0,0,0,0.08); 
            background: var(--card-hover);
        }
        
        .dash-card:hover::before { transform: scaleX(1); }

        .dash-icon { 
            font-size: 3rem; 
            color: var(--theme); 
            margin-bottom: 15px; 
            background: rgba(9, 132, 227, 0.1);
            width: 80px;
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            transition: 0.3s;
        }
        
        .dash-card:hover .dash-icon { background: var(--theme); color: var(--white); transform: scale(1.1); }

        .dash-title { margin: 0 0 10px 0; font-size: 1.3rem; color: var(--dark); font-weight: 700; }
        .dash-desc { margin: 0; font-size: 0.9rem; color: var(--text-muted); }

    </style>
</head>
<body>

    <div class="admin-header">
        <h1 class="header-title"><i class="fas fa-store"></i> FoodieDash Admin</h1>
        <a href="Welcome.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="dashboard-container">
        
        <div class="welcome-text">
            <h2>Welcome back, Manager! 👋</h2>
            <p>What would you like to manage today?</p>
        </div>

        <div class="dash-grid">
            
            <a href="order.jsp" class="dash-card">
                <div class="dash-icon"><i class="fas fa-clipboard-list"></i></div>
                <h3 class="dash-title">Current Orders</h3>
                <p class="dash-desc">View and manage incoming customer orders in real-time.</p>
            </a>

            <a href="Torder.jsp" class="dash-card">
                <div class="dash-icon"><i class="fas fa-calendar-day"></i></div>
                <h3 class="dash-title">Order's Summary</h3>
                <p class="dash-desc">View the summary and total revenue of all orders placed today.</p>
            </a>

            <a href="hotelmenu.jsp" class="dash-card">
                <div class="dash-icon"><i class="fas fa-utensils"></i></div>
                <h3 class="dash-title">Update Menu</h3>
                <p class="dash-desc">Add new items, change prices, or remove unavailable food.</p>
            </a>

            <a href="UpdateBanner.jsp" class="dash-card">
                <div class="dash-icon"><i class="fas fa-images"></i></div>
                <h3 class="dash-title">Update Banner</h3>
                <p class="dash-desc">Change the promotional images shown on the customer home page.</p>
            </a>

            <a href="UpdateCoupon.jsp" class="dash-card">
                <div class="dash-icon"><i class="fas fa-tags"></i></div>
                <h3 class="dash-title">Update Coupons</h3>
                <p class="dash-desc">Create or manage discount codes like SAVE50 and FOODIE10.</p>
            </a>

        </div>
    </div>

</body>
</html>