package DB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Check {
	public static boolean register(String name, String email,String phone, String address, String password) {
		boolean status =false;
		try {
			Connection con=DBConection.getconnection();
			PreparedStatement ps=con.prepareStatement("insert into Customer(name, email, phone, address, password) values (?,?,?,?,?)");
			ps.setString(1, name);
			ps.setString(2, email);
			ps.setString(3, phone);
            ps.setString(4, address);
			ps.setString(5, password);
			status=ps.executeUpdate()>0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return status;
	}
	public static boolean login(String email, String password) {
		boolean status=false;
		try {
			Connection con=DBConection.getconnection();
			PreparedStatement ps=con.prepareStatement("select * from Customer  where email=? and password=?");
			ps.setString(1, email);
			ps.setString(2, password);
			ResultSet rs=ps.executeQuery();
			status=rs.next();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return status;
	}
	
}
