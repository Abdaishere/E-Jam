import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class main {
    public static void main(String[] args)
    {
        String url = "jdbc:sqlserver://desktop-fhd1jr4\\sqlexp:1433;databaseName=student;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String password = "123456";

        try {
            Connection connection = DriverManager.getConnection(url, user, password);
            Statement statement = connection.createStatement();
            //statement.executeQuery("DELETE FROM student_info");
            long start = System.currentTimeMillis();
            for (int i=1;i<=1e6;i++)
            {
                String sqlQuery = "INSERT INTO student_info (name, mark) "+"VALUES('john', "+String.valueOf(i)+")";
                int status = statement.executeUpdate(sqlQuery);
            }
            long end = System.currentTimeMillis();
            long result = end - start;
            System.out.println("took "+result+" milliseconds");
        }catch (SQLException e)
        {
            System.out.println("error with connection");
            e.printStackTrace();
        }

    }
}
