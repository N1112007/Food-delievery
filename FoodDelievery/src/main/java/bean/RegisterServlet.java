package bean;

import java.io.IOException;

import DB.Check;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class RegisterServlet extends HttpServlet{
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String address = request.getParameter("address");
    String password = request.getParameter("password");

    
    boolean isRegistered = Check.register(name, email, phone, address, password);
    
    if (isRegistered) {
        response.sendRedirect("login.jsp");
    } else 
        response.sendRedirect("error.jsp");
}
}
