# Mercury for Telegram
<img width="2458" alt="Git Banner" src="https://github.com/mercurytelegram/Mercury/assets/49677462/e4b9fd02-72a2-45c0-ad72-8d6ec4de1c89">
<br></br>


Mercury is an open-source Telegram client designed specifically for the Apple Watch. It delivers a native and standalone experience, allowing you to send and receive Telegram messages directly from your wrist without relying on your iPhone.

<a href="https://testflight.apple.com/join/4rLEiEzE">
  <img src="https://github.com/user-attachments/assets/7fe1142c-9d33-4e5b-88ca-d5a6f0b1d93a" alt="Download on TestFlight" width="180">
</a>

## Features
### Login
- Login with QR Code
- Login with credentials (in development)
- 2FA Password
- Demo with mock data

### Chat List
- Chat preview (name, image, last message)
- Unread messages, mention and reaction count badge
- Is typing/recording status
- Online status

### Supported Messages
- Text (Bold, Italic, Monospaced, Underline, Strikethrough, Mention, Spoiler, Quote)
- Image
- Audio
- Reactions
- Sticker webp (webm, tgs in development)
- Location and Venues

### Sending
- Text
- Audio
- Reactions 
- Stickers (in development)

## How to Build  

If you want to build the project yourself, you'll need to generate your own **Telegram API Hash** and **ID**. Follow these steps:  

1. **Generate Telegram API Credentials**  
   - Visit [this page](https://core.telegram.org/api/obtaining_api_id) to obtain your **API Hash** and **API ID**.  

2. **Modify the Secret Service File**  
   - Navigate to [`SecretService-sample.swift`](https://github.com/mercurytelegram/Mercury/blob/main/Mercury%20Watch%20App/Utils/Services/SecretService-sample.swift).  
   - Rename the `SecretService_Sample` enum to `SecretService`.  

3. **Add Your Credentials**  
   - Insert the **API Hash** and **API ID** you obtained in Step 1 into the `static` properties of the `SecretService` enum.  

4. **Build and Run**  
   - You're all set! Build and run the project in Xcode. 🚀

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests to make **Mercury for Telegram** even better!

## Contact  

Feel free to reach out to us on Telegram:  
- **Alessandro Alberti**: [@AlessandroAlberti](https://t.me/AlessandroAlberti)  
- **Marco Tammaro**: [@MarcoTammaro](https://t.me/MarcoTammaro)  


