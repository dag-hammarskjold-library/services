import java.io.*;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.xml.sax.SAXException;

@WebServlet("/Transform")
public class Transform
{
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    // First let's extract these if they're present in the query string
    String url = request.getParameter("url");
    String format = request.getParameter("format");
    
    // Next let's test to see what arrived.
    if(!format.isEmpty() && format == "xml") {
      // send XML
      response.setContentType("text/xml");
    } else {
      // send JSON
      response.setContentType("application/json");
    }
    
    // Definitely want to whitelist this; might be best to set it through external config
    if(!url.isEmpty() && url.contains()) {
      
    } else {
      // No need to open this up as an external service, right?  
    }
  }
}
