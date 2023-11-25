# sipinter_mail service
Mail sender service for SIPINTER app build with Python

example request 

```
curl --location 'http://127.0.0.1:8081/api/send_email' \
--header 'Content-Type: application/json' \
--data-raw '{
    "to" : "faisolofficial99@gmail.com",
    "subject" : "Testing Email",
    "recipient" : "SMK Ma'\''arif Tegal",
    "content" : "<p>This is a modern email template. You can customize it as per your needs. Make sure to test it across various email clients for compatibility.</p>  <div class='\''button'\''> <a href='\''#'\'' class='\''cta-button'\''>Readme</a> </div> <p>Feel free to contact us if you have any questions or need assistance.</p>"
}'
```

