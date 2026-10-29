package DB;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConection {
	public static Connection getconnection(){
		Connection con= null;
		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
			con=DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe","system","root");
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return con;
	}
}
// Customer
// items altered and added img_url & DietType(Veg,Non-veg)
// riders 
// orders
//banner
//COUPONS
//RATING