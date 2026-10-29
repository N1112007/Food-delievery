<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Item Management | FoodieDash Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        /* --- CORE STYLES EXTRACTED FROM ORDERS PAGE --- */
        :root {
            --dark: #2d3436; 
            --light: #f9f9fb; 
            --white: #ffffff;
            --text-muted: #636e72; 
            --theme: #0984e3; 
            --success: #27ae60; 
            --warning: #f39c12;
            --danger: #e74c3c; /* Added for delete buttons */
        }
        body { font-family: 'Poppins', sans-serif; margin: 0; background-color: var(--light); padding: 20px; }
        
        .admin-container { max-width: 1000px; margin: auto; }

        /* --- HEADER --- */
        .page-header { display: flex; align-items: center; gap: 15px; margin-bottom: 25px; background: var(--white); padding: 20px; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .back-btn { color: var(--dark); font-size: 1.5rem; text-decoration: none; transition: 0.2s; }
        .back-btn:hover { color: var(--theme); transform: translateX(-3px); }
        .page-header h1 { margin: 0; color: var(--dark); font-weight: 800; font-size: 1.5rem;}

        /* --- CONTENT BOXES --- */
        .content-box { background: var(--white); border-radius: 15px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); margin-bottom: 25px; }

        /* --- ALERTS --- */
        .alert { padding: 15px; border-radius: 10px; margin-bottom: 20px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
        .alert-success { background: rgba(39, 174, 96, 0.1); color: var(--success); border: 1px solid rgba(39, 174, 96, 0.2); }
        .alert-error { background: rgba(231, 76, 60, 0.1); color: var(--danger); border: 1px solid rgba(231, 76, 60, 0.2); }

        /* --- FORM STYLES --- */
        form { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group { display: flex; flex-direction: column; }
        .form-group.full-width { grid-column: span 2; }
        
        label { color: var(--text-muted); font-weight: 600; font-size: 0.85rem; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px;}
        
        input, select, textarea { padding: 12px; border: 2px solid #edf2f7; border-radius: 8px; font-family: 'Poppins', sans-serif; font-size: 0.95rem; color: var(--dark); transition: 0.3s; outline: none; background: var(--light); }
        input:focus, select:focus, textarea:focus { border-color: var(--theme); background: var(--white); }

        /* --- BUTTONS --- */
        .btn { padding: 12px 20px; border: none; border-radius: 8px; font-weight: 600; font-family: 'Poppins', sans-serif; cursor: pointer; transition: 0.2s; color: white; display: inline-flex; align-items: center; justify-content: center; gap: 8px;}
        .btn-primary { background: var(--theme); }
        .btn-primary:hover { background: #076ebf; transform: translateY(-2px); }
        .btn-secondary { background: #95a5a6; }
        .btn-secondary:hover { background: #7f8c8d; transform: translateY(-2px); }

        /* --- TABLE STYLES --- */
        .table-container { overflow-x: auto; }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .table-header h2 { margin: 0; color: var(--dark); font-weight: 800; font-size: 1.3rem; }
        table { width: 100%; border-collapse: collapse; min-width: 800px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #edf2f7; }
        th { background-color: #f8fafc; color: var(--text-muted); font-weight: 600; text-transform: uppercase; font-size: 0.85rem; letter-spacing: 0.5px; }
        td { color: var(--dark); font-size: 0.95rem; vertical-align: middle; }
        tr:hover { background-color: #f8fafc; }

        /* Table Action Buttons */
        .action-btn { padding: 6px 12px; border-radius: 6px; font-size: 0.85rem; font-weight: 600; cursor: pointer; border: 1px solid transparent; transition: 0.2s; font-family: 'Poppins'; }
        .btn-edit { background: rgba(243, 156, 18, 0.1); color: var(--warning); border-color: rgba(243, 156, 18, 0.3); }
        .btn-edit:hover { background: var(--warning); color: white; }
        .btn-delete { background: rgba(231, 76, 60, 0.1); color: var(--danger); border-color: rgba(231, 76, 60, 0.3); }
        .btn-delete:hover { background: var(--danger); color: white; }
        
        .action-cell { display: flex; gap: 10px; align-items: center; }
    </style>
</head>
<body>

<div class="admin-container">
    
    <div class="page-header">
        <a href="HotelDashbord.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
        <h1><i class="fas fa-utensils" style="color: var(--theme);"></i> Item Management</h1>
    </div>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String message = "";
        String msgType = "success"; // success or error
        
        try {
            // 1. Establish Connection
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "root");
            
            // 2. Handle CRUD Operations (POST requests)
            String action = request.getParameter("action");
            if (action != null) {
                String idStr = request.getParameter("PRODUCT_ID");
                String name = request.getParameter("ITEM_NAME");
                String desc = request.getParameter("DESCRIPTION");
                String priceStr = request.getParameter("PRICE");
                String imgUrl = request.getParameter("item_img");
                String diet = request.getParameter("DietType");
                
                int prodId = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : 0;
                double price = (priceStr != null && !priceStr.isEmpty()) ? Double.parseDouble(priceStr) : 0.0;

                if ("add".equals(action)) {
                    String sql = "INSERT INTO items (PRODUCT_ID, ITEM_NAME, DESCRIPTION, PRICE, item_img, DietType) VALUES (?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, prodId);
                    pstmt.setString(2, name);
                    pstmt.setString(3, desc);
                    pstmt.setDouble(4, price);
                    pstmt.setString(5, imgUrl);
                    pstmt.setString(6, diet);
                    pstmt.executeUpdate();
                    message = "Item successfully added to the menu!";
                } 
                else if ("update".equals(action)) {
                    String sql = "UPDATE items SET ITEM_NAME=?, DESCRIPTION=?, PRICE=?, item_img=?, DietType=? WHERE PRODUCT_ID=?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, name);
                    pstmt.setString(2, desc);
                    pstmt.setDouble(3, price);
                    pstmt.setString(4, imgUrl);
                    pstmt.setString(5, diet);
                    pstmt.setInt(6, prodId);
                    pstmt.executeUpdate();
                    message = "Menu item successfully updated!";
                } 
                else if ("delete".equals(action)) {
                    String sql = "DELETE FROM items WHERE PRODUCT_ID=?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, prodId);
                    pstmt.executeUpdate();
                    message = "Item removed from the menu.";
                }
            }
    %>

    <% if (!message.isEmpty()) { %>
        <div class="alert alert-<%= msgType %>">
            <i class="fas <%= msgType.equals("success") ? "fa-check-circle" : "fa-exclamation-circle" %>"></i>
            <%= message %>
        </div>
    <% } %>

    <div class="content-box">
        <form method="post" id="crudForm">
            <input type="hidden" name="action" id="formAction" value="add">
            
            <div class="form-group">
                <label>Product ID (Unique)</label>
                <input type="text" name="PRODUCT_ID" id="PRODUCT_ID" placeholder="e.g. 101" required>
            </div>
            <div class="form-group">
                <label>Item Name</label>
                <input type="text" name="ITEM_NAME" id="ITEM_NAME" placeholder="e.g. Classic Cheeseburger" required>
            </div>
            <div class="form-group">
                <label>Price (₹)</label>
                <input type="number" step="0.01" name="PRICE" id="PRICE" placeholder="0.00" required>
            </div>
            <div class="form-group">
                <label>Diet Type</label>
                <select name="DietType" id="DietType">
                    <option value="Veg">Vegetarian</option>
                    <option value="Non-Veg">Non-Vegetarian</option>
                </select>
            </div>
            <div class="form-group full-width">
                <label>Image URL</label>
                <input type="text" name="item_img" id="item_img" placeholder="https://example.com/image.jpg">
            </div>
            <div class="form-group full-width">
                <label>Description</label>
                <textarea name="DESCRIPTION" id="DESCRIPTION" rows="3" placeholder="Enter a delicious description..."></textarea>
            </div>
            
            <div class="form-group full-width" style="flex-direction: row; gap: 15px; margin-top: 10px;">
                <button type="submit" id="submitBtn" class="btn btn-primary"><i class="fas fa-plus"></i> Add Item</button>
                <button type="button" onclick="resetForm()" class="btn btn-secondary"><i class="fas fa-undo"></i> Clear Form</button>
            </div>
        </form>
    </div>

    <div class="content-box table-container">
        <div class="table-header">
            <h2>Current Menu Items</h2>
        </div>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Price</th>
                    <th>Diet</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    // READ
                    pstmt = conn.prepareStatement("SELECT * FROM items ORDER BY PRODUCT_ID ASC");
                    rs = pstmt.executeQuery();
                    while(rs.next()) {
                        int id = rs.getInt("PRODUCT_ID");
                        String name = rs.getString("ITEM_NAME");
                        String desc = rs.getString("DESCRIPTION");
                        double price = rs.getDouble("PRICE");
                        String img = rs.getString("item_img");
                        String diet = rs.getString("DietType");
                        
                        // Improved escaping for JS function
                        String jsName = name != null ? name.replace("'", "\\'").replace("\"", "&quot;") : "";
                        String jsDesc = desc != null ? desc.replace("'", "\\'").replace("\"", "&quot;").replace("\n", "\\n").replace("\r", "") : "";
                        String jsImg = img != null ? img.replace("'", "\\'") : "";
                        String jsDiet = diet != null ? diet.replace("'", "\\'") : "Veg";
                        
                        // Color code the diet type text slightly for better UI
                        String dietColor = "Veg".equalsIgnoreCase(diet) ? "color: var(--success);" : "color: var(--danger);";
                %>
                <tr>
                    <td><strong>#<%= id %></strong></td>
                    <td><strong><%= name %></strong></td>
                    <td>₹<%= String.format("%.2f", price) %></td>
                    <td><strong style="<%= dietColor %>"><%= diet %></strong></td>
                    <td>
                        <div class="action-cell">
                            <button type="button" class="action-btn btn-edit" onclick="editItem('<%= id %>', '<%= jsName %>', '<%= price %>', '<%= jsDiet %>', '<%= jsImg %>', '<%= jsDesc %>')">
                                <i class="fas fa-pen"></i> Edit
                            </button>
                            
                            <form method="post" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this item?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="PRODUCT_ID" value="<%= id %>">
                                <button type="submit" class="action-btn btn-delete"><i class="fas fa-trash"></i> Delete</button>
                            </form>
                        </div>
                    </td>
                </tr>
                <%
                    } // end while
                } catch(Exception e) {
                    out.println("<tr><td colspan='5'><div class='alert alert-error'>Database Error: " + e.getMessage() + "</div></td></tr>");
                } finally {
                    if(rs != null) try { rs.close(); } catch(SQLException e) {}
                    if(pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
                    if(conn != null) try { conn.close(); } catch(SQLException e) {}
                }
                %>
            </tbody>
        </table>
    </div>

</div>

<script>
    // JavaScript to handle populating the form for Updates
    function editItem(id, name, price, diet, img, desc) {
        document.getElementById("formAction").value = "update";
        document.getElementById("PRODUCT_ID").value = id;
        document.getElementById("PRODUCT_ID").readOnly = true; 
        document.getElementById("ITEM_NAME").value = name;
        document.getElementById("PRICE").value = price;
        document.getElementById("DietType").value = diet;
        document.getElementById("item_img").value = img;
        document.getElementById("DESCRIPTION").value = desc;
        
        let btn = document.getElementById("submitBtn");
        btn.innerHTML = "<i class='fas fa-save'></i> Update Item";
        btn.style.background = "var(--warning)"; 
        
        window.scrollTo({ top: 0, behavior: 'smooth' }); 
    }

    function resetForm() {
        document.getElementById("crudForm").reset();
        document.getElementById("formAction").value = "add";
        document.getElementById("PRODUCT_ID").readOnly = false;
        
        let btn = document.getElementById("submitBtn");
        btn.innerHTML = "<i class='fas fa-plus'></i> Add Item";
        btn.style.background = "var(--theme)";
    }
</script>

</body>
</html>