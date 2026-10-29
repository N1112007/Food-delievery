package bean;

import java.io.IOException;

import DB.Check1;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterServlet1 extends HttpServlet{
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	 String name = request.getParameter("name");
	    String phone = request.getParameter("phone");
	    String Vehicle = request.getParameter("vehicle_no.");
	    String password = request.getParameter("password");

	    
	    boolean isRegistered = Check1.register1(name, phone, Vehicle, password);
	    
	    if (isRegistered) {
	        response.sendRedirect("login1.jsp");
	    } else 
	        response.sendRedirect("error.jsp");
}
}
