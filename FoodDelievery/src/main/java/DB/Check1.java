package DB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Check1 {
    
    public static boolean register1(String name, String phone, String Vehicle, String password) {
        boolean status = false;
        try {
            Connection con = DBConection.getconnection();
            
            String sql = "INSERT INTO riders (RIDER_NAME, PHONE_NO, VEHICLE_NO, PASSWORD) VALUES (?, ?, ?, ?)";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);     // Matches RIDER_NAME
            ps.setString(2, phone);    // Matches PHONE_NO
            ps.setString(3, Vehicle);  // Matches VEHICLE_NO
            ps.setString(4, password); // Matches PASSWORD
            
            status = ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }
    
    public static boolean login1(String name, String password) {
        boolean status = false;
        try {
            Connection con = DBConection.getconnection();
            
            // Fixed the column names to match your database structure
            PreparedStatement ps = con.prepareStatement("SELECT * FROM riders WHERE RIDER_NAME=? AND PASSWORD=?");
            ps.setString(1, name);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            
            // If rs.next() is true, the login is successful!
            if (rs.next()) {
                status = true;
                
                // Now, update the status to 'online'
                String updateSql = "UPDATE riders SET CURRENT_STATUS = 'online' WHERE RIDER_NAME = ?";
                PreparedStatement updatePs = con.prepareStatement(updateSql);
                updatePs.setString(1, name);
                updatePs.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }

    // NEW METHOD: Call this when the rider logs out
    public static boolean logout1(String name) {
        boolean status = false;
        try {
            Connection con = DBConection.getconnection();
            
            // Update the status to 'offline'
            String updateSql = "UPDATE riders SET CURRENT_STATUS = 'offline' WHERE RIDER_NAME = ?";
            PreparedStatement ps = con.prepareStatement(updateSql);
            ps.setString(1, name);
            
            status = ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }
}