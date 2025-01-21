# Mercury for Telegram
<img width="2458" alt="Git Banner" src="https://github.com/mercurytelegram/Mercury/assets/49677462/e4b9fd02-72a2-45c0-ad72-8d6ec4de1c89">
<br></br>



Mercury is an open-source Telegram client designed specifically for the Apple Watch. It delivers a native and standalone experience, allowing you to send and receive Telegram messages directly from your wrist without relying on your iPhone. 
More info available [here](https://alessandro-alberti.notion.site/mercury).


<a href="https://testflight.apple.com/join/dCndzeB1">
  <img src="https://github.com/user-attachments/assets/86f3a622-ed56-485e-8572-b046c56d64bf" alt="Download on TestFlight" width="180">
</a>


## Main Features  

### **Privacy-Focused and Open-Source**  
Mercury’s code is fully open-source, so anyone can verify it handles user data responsibly and transparently.  

### **True Standalone Experience**  
Enjoy Telegram on your Apple Watch without needing an iPhone. Mercury works independently, so you stay connected wherever you are.  

### **Modern Design, Cutting-Edge Technology**  
Built with the latest Apple technologies and APIs, Mercury delivers a sleek, intuitive design for a seamless user experience.  
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

The features changelog is available [here](https://alessandro-alberti.notion.site/mercury-changelog).

## Contact  

Feel free to reach out to us on Telegram:  
- **Alessandro Alberti**: [@AlessandroAlberti](https://t.me/AlessandroAlberti)  
- **Marco Tammaro**: [@MarcoTammaro](https://t.me/MarcoTammaro)  


