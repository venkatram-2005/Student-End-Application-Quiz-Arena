<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Quiz Results</title>
    <style>
        body {
    margin: 0;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background: linear-gradient(135deg, #9C27B0, #673AB7); /* Updated to purple haze gradient */
    font-family: Arial, sans-serif;
}

.container {
    width: 100%;
    max-width: 900px;
    background: rgba(255, 255, 255, 0.1); /* Slightly more transparent for modern look */
    border-radius: 8px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
    padding: 30px;
    text-align: center;
}

h1 {
    color: #fff; /* Changed to white */
    font-size: 2.5em;
    margin-bottom: 20px;
}

p {
    font-size: 1.2em;
    color: #fff; /* Changed to white */
    margin: 10px 0;
}

.results {
    margin-top: 20px;
}

.donut-chart {
    margin-top: 30px;
}

.button-container {
    margin-top: 20px;
}

button {
    padding: 10px 20px;
    border: none;
    border-radius: 5px;
    background: linear-gradient(135deg, #9C27B0, #673AB7); /* Purple haze background */
    color: #fff; /* Changed to white */
    font-size: 16px;
    cursor: pointer;
    transition: background 0.3s;
}

button:hover {
    background: linear-gradient(135deg, #7B1FA2, #512DA8); /* Slightly darker purple haze on hover */
}
        
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>

    <div class="container">
        <h1>Quiz Results</h1>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/quizarena?allowPublicKeyRetrieval=true&useSSL=false";  
            String dbUser = "root";  
            String dbPassword = "valluri200513";  
            String subjectName = request.getParameter("subjectName"); // Get subject name from form
            int totalQuestions = 0;
            int correctAnswers = 0;

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                // Connect to the database
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
                
                // Create SQL query to fetch questions for the selected subject
                String sql = "SELECT * FROM " + subjectName;  
                stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);

                // Evaluate answers
                while (rs.next()) {
                    int questionId = rs.getInt("id");
                    String correctAnswer = rs.getString("answer_option");
                    String studentAnswer = request.getParameter("answer_" + questionId); // Get student's answer

                    // Count total questions and correct answers
                    totalQuestions++;
                    if (correctAnswer.equals(studentAnswer)) {
                        correctAnswers++;
                    }
                }

                // Calculate score
                double scorePercentage = (double) correctAnswers / totalQuestions * 100;
                int wrongAnswers = totalQuestions - correctAnswers;

                // Display results
                out.println("<div class='results'>");
                out.println("<p>Total Questions: " + totalQuestions + "</p>");
                out.println("<p>Correct Answers: " + correctAnswers + "</p>");
                out.println("<p>Wrong Answers: " + wrongAnswers + "</p>");
                out.println("<p>Score: " + scorePercentage + "%</p>");
                out.println("</div>");
                
                // After displaying the score
                out.println("<div class='button-container'><a href='leaderboard.jsp?subjectName=" + subjectName + "'><button>View Leaderboard</button></a></div>");

                // Store the results in the database (if needed)
                String studentName = "Student"; // Get the student's name, e.g., from a session variable
                String insertSQL = "INSERT INTO QuizResults (student_name, subject_name, score) VALUES (?, ?, ?)";
                PreparedStatement pstmt = conn.prepareStatement(insertSQL);
                pstmt.setString(1, studentName);
                pstmt.setString(2, subjectName);
                pstmt.setDouble(3, scorePercentage);
                pstmt.executeUpdate();

            } catch (Exception e) {
                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            } finally {
                try { if (rs != null) rs.close(); } catch (SQLException e) {}
                try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
                try { if (conn != null) conn.close(); } catch (SQLException e) {}
            }
        %>

        <!-- Donut Chart for correct vs wrong answers -->
        <div class="donut-chart">
            <canvas id="resultsChart" width="400" height="400"></canvas>
        </div>

        <script>
            // Chart.js to show correct vs wrong answers
            var ctx = document.getElementById('resultsChart').getContext('2d');
            var resultsChart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Correct Answers', 'Wrong Answers'],
                    datasets: [{
                        data: [<%= correctAnswers %>, <%= totalQuestions - correctAnswers %>],
                        backgroundColor: ['#4caf50', '#f44336'],
                        borderColor: ['#4caf50', '#f44336'],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        position: 'bottom',
                    },
                    title: {
                        display: true,
                        text: 'Quiz Results Breakdown'
                    }
                }
            });
        </script>
    </div>

</body>
</html>
