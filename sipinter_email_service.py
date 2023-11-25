import smtplib
import uuid
import threading
from flask import Flask, request, jsonify

app = Flask(__name__)

# Set your email credentials and details
sender_email = "awscloud221@gmail.com"
sender_password = "fyexijkhzkrdrcjm"

# Read HTML content from file
with open("email_template.html", "r") as file:
    html_content = file.read()

# Construct the email message
message = """\
Subject: {{subject}}
To: {{receiver_email}}
From: {{sender_email}}
Content-Type: text/html

{{html_content}}
"""

@app.route('/api/send_email', methods=['POST'])
def emailService():
    trxid = uuid.uuid4()
    try:
        global html_content, message
        # Get JSON data from the request body
        data = request.get_json()
        app.logger.info("[{}] received request with body : {}".format(trxid, data))

        receiver_email = data["to"]
        subject = data["subject"]
        recipient = data["recipient"]
        content = data["content"]

        html_content = html_content.replace("{{recipient}}", recipient).replace("{{email_content}}", content)
        message = message.replace("{{subject}}", subject).replace("{{receiver_email}}", receiver_email).replace("{{sender_email}}", sender_email).replace("{{html_content}}", html_content)
        
        # Send email in a separate thread
        send_email_in_thread(trxid, sender_email, receiver_email, message)
            
        # Return a JSON response
        result = {"message": "success"}
        return jsonify(result), 200

    except Exception as e:
        # Handle exceptions
        app.logger.info("[{}] send email error : {}".format(trxid, str(e)))
        error_message = {"error": str(e)}
        return jsonify(error_message), 500

def send_email(trxid, sender_email, receiver_email, message):
    # Connect to the SMTP server (in this case, using Gmail's SMTP server)
    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.starttls()
        server.login(sender_email, sender_password)

        # Send the email
        server.sendmail(sender_email, receiver_email, message)

    app.logger.info("[{}] Email sent successfully!".format(trxid))

def send_email_in_thread(trxid, sender_email, receiver_email, message):
    # Create a thread for sending the email
    email_thread = threading.Thread(target=send_email, args=(trxid, sender_email, receiver_email, message))

    # Start the thread
    email_thread.start()

if __name__ == '__main__':
    app.run(debug=True)
    # app.run(port=8081)