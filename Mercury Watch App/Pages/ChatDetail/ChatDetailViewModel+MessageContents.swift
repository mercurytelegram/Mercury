//
//  ChatDetailViewModel+MessageContents.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/10/24.
//

import SwiftUI
import TDLibKit
import SDWebImageWebPCoder

extension ChatDetailViewModel {

    func messageContentFrom(_ msg: Message) async ->  MessageModel.MessageContent {
        switch msg.content {

        case .messageText(let message):
            return textContentOrFallback(message.text.attributedString, message: msg)

        case .messageVoiceNote(let message):
            guard var model = await message.getModel()
            else { return textContentOrFallback(msg.description, message: msg) }
            model.onPress = { self.setMessageAsOpened(msg.id) }
            return .voiceNote(model: model)

        case .messagePhoto(let message):
            return .photo(model: message.getModel(), caption: message.caption.attributedString)

        case .messageAnimation(let message):
            return .animation(model: message.getModel(), caption: message.caption.attributedString)

        case .messageVideoNote(let message):
            var model = message.getModel()
            model.onPress = { self.setMessageAsOpened(msg.id) }
            return .videoNote(model: model)

        case .messageSticker(let message):
            switch message.sticker.format {

            case .stickerFormatWebp:
                return .stickerImage(model: message.getImageModel())
            case .stickerFormatTgs:
                return unsupportedContent(msg, fallback: "Animated sticker not supported")
            case .stickerFormatWebm:
                return unsupportedContent(msg, fallback: "Video sticker not supported")
            }

        case .messageLocation(let message):
            return .location(model: message.getModel())

        case .messageVenue(let message):
            return .location(model: message.getModel())

        case .messagePinMessage(_):
            return await getPillModel(message: msg, text: "pinned a message")

        case .messageChatChangeTitle(let message):
            return await getPillModel(
                message: msg,
                text: "changed the group name to _\(message.title)_"
            )

        case .messageChatChangePhoto(_):
            return await getPillModel(
                message: msg,
                text: "changed group photo"
            )

        case .messageVideoChatScheduled(_):
            return await getPillModel(message: msg, text: "scheduled a video chat")
            
        case .messageVideoChatStarted(_):
            return await getPillModel(message: msg, text: "started a video chat")
            
        case .messageVideoChatEnded(let message):
            let duration = message.duration
            let formatString = duration > 0 ? "ended the video chat (\(duration)s)" : "ended the video chat"
            return await getPillModel(message: msg, text: LocalizedStringKey(formatString))
            
        case .messageInviteVideoChatParticipants(_):
            return await getPillModel(message: msg, text: "invited to video chat")
            
        case .messageCall(_):
            return await getPillModel(message: msg, text: "Call")
            
        case .messageDocument(_):
            return textContentOrFallback(msg.description, message: msg)
            
        case .messageAudio(_):
            return textContentOrFallback(msg.description, message: msg)
            
        case .messagePoll(let message):
            return textContentOrFallback(message.previewText, message: msg)
            
        case .messageContact(_):
            return textContentOrFallback(msg.description, message: msg)

        case .messageVideo(_):
            return textContentOrFallback(msg.description, message: msg)

        case .messageAnimatedEmoji(_):
            return textContentOrFallback(msg.description, message: msg)

        case .messageDice(_):
            return textContentOrFallback(msg.description, message: msg)

        case .messageStakeDice(_):
            return textContentOrFallback(msg.description, message: msg)
            
        case .messageChatAddMembers(_):
            return await getPillModel(message: msg, text: "joined the group")
            
        case .messageChatJoinByLink:
            return await getPillModel(message: msg, text: "joined by invite link")
            
        case .messageChatDeleteMember(_):
            return await getPillModel(message: msg, text: "left the group")

        case .messageChatDeletePhoto:
            return await getPillModel(message: msg, text: "deleted group photo")

        case .messageChatOwnerLeft(_):
            return await getPillModel(message: msg, text: "left ownership of the chat")

        case .messageChatOwnerChanged(_):
            return await getPillModel(message: msg, text: "changed chat owner")

        case .messageChatHasProtectedContentToggled(let message):
            let text = message.newHasProtectedContent ? "enabled protected content" : "disabled protected content"
            return await getPillModel(message: msg, text: LocalizedStringKey(text))

        case .messageChatHasProtectedContentDisableRequested(let message):
            let text = message.isExpired ? "protected content request expired" : "requested to disable protected content"
            return await getPillModel(message: msg, text: LocalizedStringKey(text))

        case .messageChatJoinByRequest:
            return await getPillModel(message: msg, text: "joined by request")
            
        case .messageBasicGroupChatCreate(_):
            return await getPillModel(message: msg, text: "created the group")
            
        case .messageSupergroupChatCreate(_):
            return await getPillModel(message: msg, text: "created the supergroup")
            
        case .messageChatUpgradeTo(_):
            return await getPillModel(message: msg, text: "upgraded to supergroup")
            
        case .messageChatUpgradeFrom(_):
            return await getPillModel(message: msg, text: "upgraded from basic group")
            
        case .messageForumTopicCreated(_):
            return await getPillModel(message: msg, text: "created a topic")
            
        case .messageForumTopicEdited(let message):
            if message.name.isEmpty {
                return await getPillModel(message: msg, text: "edited the topic")
            }
            return await getPillModel(message: msg, text: "renamed the topic to _\(message.name)_")
            
        case .messageForumTopicIsClosedToggled(let message):
            return await getPillModel(message: msg, text: message.isClosed ? "closed the topic" : "reopened the topic")
            
        case .messageForumTopicIsHiddenToggled(let message):
            return await getPillModel(message: msg, text: message.isHidden ? "hid the General topic" : "unhid the General topic")

        case .messageScreenshotTaken:
            return await getPillModel(message: msg, text: "took a screenshot")

        case .messageChatSetBackground(_):
            return await getPillModel(message: msg, text: "changed chat background")

        case .messageChatSetTheme(let message):
            return await getPillModel(message: msg, text: message.theme == nil ? "reset chat theme" : "changed chat theme")

        case .messageChatSetMessageAutoDeleteTime(let message):
            let text = message.messageAutoDeleteTime == 0 ? "disabled auto-delete timer" : "changed auto-delete timer"
            return await getPillModel(message: msg, text: LocalizedStringKey(text))

        case .messageChatBoost(let message):
            return await getPillModel(message: msg, text: "boosted the chat \(message.boostCount)x")

        case .messageSuggestProfilePhoto(_):
            return await getPillModel(message: msg, text: "suggested a profile photo")

        case .messageSuggestBirthdate(_):
            return await getPillModel(message: msg, text: "suggested a birthdate")

        case .messageCustomServiceAction(let message):
            return await getPillModel(message: msg, text: LocalizedStringKey(message.text))

        case .messageGameScore(let message):
            return await getPillModel(message: msg, text: "scored \(message.score) in a game")

        case .messageManagedBotCreated(_):
            return await getPillModel(message: msg, text: "created a managed bot")

        case .messagePaymentSuccessful(_):
            return await getPillModel(message: msg, text: "completed a payment")

        case .messagePaymentSuccessfulBot(_):
            return await getPillModel(message: msg, text: "received a payment")

        case .messagePaymentRefunded(_):
            return await getPillModel(message: msg, text: "refunded a payment")

        case .messageGiftedPremium(_):
            return await getPillModel(message: msg, text: "gifted Telegram Premium")

        case .messagePremiumGiftCode(_):
            return await getPillModel(message: msg, text: "created a Premium gift code")

        case .messageGiveawayCreated(_):
            return await getPillModel(message: msg, text: "created a giveaway")

        case .messageGiveaway(_):
            return await getPillModel(message: msg, text: "started a giveaway")

        case .messageGiveawayCompleted(_):
            return await getPillModel(message: msg, text: "completed a giveaway")

        case .messageGiveawayWinners(_):
            return await getPillModel(message: msg, text: "announced giveaway winners")

        case .messageGiftedStars(_):
            return await getPillModel(message: msg, text: "gifted Telegram Stars")

        case .messageGiftedTon(_):
            return await getPillModel(message: msg, text: "gifted TON")

        case .messageGiveawayPrizeStars(_):
            return await getPillModel(message: msg, text: "shared giveaway prize Stars")

        case .messageGift(_):
            return await getPillModel(message: msg, text: "sent a gift")

        case .messageUpgradedGift(_):
            return await getPillModel(message: msg, text: "upgraded a gift")

        case .messageRefundedUpgradedGift(_):
            return await getPillModel(message: msg, text: "refunded an upgraded gift")

        case .messageUpgradedGiftPurchaseOffer(_):
            return await getPillModel(message: msg, text: "sent a gift purchase offer")

        case .messageUpgradedGiftPurchaseOfferRejected(_):
            return await getPillModel(message: msg, text: "rejected a gift purchase offer")

        case .messagePaidMessagesRefunded(_):
            return await getPillModel(message: msg, text: "refunded paid messages")

        case .messagePaidMessagePriceChanged(_):
            return await getPillModel(message: msg, text: "changed paid message price")

        case .messageDirectMessagePriceChanged(_):
            return await getPillModel(message: msg, text: "changed direct message price")

        case .messageChecklistTasksDone(_):
            return await getPillModel(message: msg, text: "completed checklist tasks")

        case .messageChecklistTasksAdded(_):
            return await getPillModel(message: msg, text: "added checklist tasks")

        case .messageSuggestedPostApprovalFailed(_):
            return await getPillModel(message: msg, text: "suggested post approval failed")

        case .messageSuggestedPostApproved(_):
            return await getPillModel(message: msg, text: "approved a suggested post")

        case .messageSuggestedPostDeclined(_):
            return await getPillModel(message: msg, text: "declined a suggested post")

        case .messageSuggestedPostPaid(_):
            return await getPillModel(message: msg, text: "paid for a suggested post")

        case .messageSuggestedPostRefunded(_):
            return await getPillModel(message: msg, text: "refunded a suggested post")

        case .messageContactRegistered:
            return await getPillModel(message: msg, text: "joined Telegram")

        case .messageUsersShared(_):
            return await getPillModel(message: msg, text: "shared users")

        case .messageChatShared(_):
            return await getPillModel(message: msg, text: "shared a chat")

        case .messageBotWriteAccessAllowed(_):
            return await getPillModel(message: msg, text: "allowed bot write access")

        case .messageWebAppDataSent(_):
            return await getPillModel(message: msg, text: "sent web app data")

        case .messageWebAppDataReceived(_):
            return await getPillModel(message: msg, text: "received web app data")

        case .messagePassportDataSent(_):
            return await getPillModel(message: msg, text: "sent Telegram Passport data")

        case .messagePassportDataReceived(_):
            return await getPillModel(message: msg, text: "received Telegram Passport data")

        case .messageProximityAlertTriggered(_):
            return await getPillModel(message: msg, text: "triggered a proximity alert")
            
            
        case .messageUnsupported:
            return .pill(title: nil, description: "Message not supported")

        default:
            return unsupportedContent(msg)
        }

    }

    func textContentOrFallback(_ text: AttributedString, message: Message) -> MessageModel.MessageContent {
        if text.isBlank {
            return .text("📊 Poll")
        }

        return .text(text)
    }

    func unsupportedContent(_ message: Message, fallback: String = "Unsupported message") -> MessageModel.MessageContent {
        let text = message.description
        let description = text.isBlank ? fallback : String(text.characters)
        return .pill(title: nil, description: LocalizedStringKey(description))
    }

    func getPillModel(message: Message, text: LocalizedStringKey) async ->  MessageModel.MessageContent {
        let sender = await self.senderNameFrom(message)
        return .pill(
            title: sender.name,
            description: text
        )
    }
}

private extension AttributedString {
    var isBlank: Bool {
        String(characters).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension MessageVideoNote {
    func getModel() -> VideoNoteModel {
        return VideoNoteModel(
            thumbnail: videoNote.getAsyncModel(),
            duration: videoNote.duration,
            isSecret: isSecret,
            isViewed: isViewed,
            getVideoURL: {
                await FileService.getStreamingFilePath(for: videoNote.video)
            }
        )
    }
}

extension MessageVoiceNote {
    func getModel() async -> VoiceNoteModel? {
        return VoiceNoteModel(
            isListened: self.isListened,
            getPlayer: {
                guard let file = await FileService.getFilePath(for: voiceNote.voice),
                      let player = try? PlayerService(audioFilePath: file)
                else { return nil }
                return player
            }
        )
    }
}

extension MessagePhoto {
    func getModel() -> AsyncImageModel {
        var thumbnail: UIImage? = nil
        if let data = photo.minithumbnail?.data {
            thumbnail = UIImage(data: data)
        }
        return AsyncImageModel(
            thumbnail: thumbnail,
            getImage: {
                guard let photo = photo.lowRes
                else { return nil }
                return await FileService.getImage(for: photo)
            }
        )
    }
}

extension MessageSticker {
    func getImageModel() -> StickerImageModel {
        return StickerImageModel(
            emoji: sticker.emoji,
            getImage: {
                guard let filePath = await FileService.getFilePath(for: sticker.sticker),
                      let data = try? Data(contentsOf: filePath)
                else { return nil }
                return SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
            }
        )
    }
}

extension MessageLocation {
    func getModel() -> LocationModel {
        return LocationModel(
            coordinate: CLLocationCoordinate2D(
                latitude: self.location.latitude,
                longitude: self.location.longitude
            )
        )
    }
}

extension MessageVenue {
    func getModel() -> LocationModel {
        let style = pinStyle()

        return LocationModel(
            title: venue.title,
            coordinate: CLLocationCoordinate2D(
                latitude: venue.location.latitude,
                longitude: venue.location.longitude
            ),
            color: style.color,
            markerSymbol: style.symbol
        )
    }

    private func pinStyle() -> (symbol: String, color: Color) {
        switch venue.type {
        case "arts_entertainment/museum":
            return ("building.columns.fill", .pink)
        case "travel/hotel":
            return ("bed.double.fill", .purple)
        case let type where type.contains("food"):
            return ("fork.knife", .orange)
        case let type where type.contains("parks_outdoors"):
            return ("tree.fill", .green)
        case let type where type.contains("shops"):
            return ("bag.fill", .yellow)
        case let type where type.contains("building"):
            return ("building.2.fill", .gray)
        default:
            return ("mapin", .red)
        }
    }
}

extension MessageAnimation {
    func getModel() -> AnimationModel {
        return AnimationModel(
            thumbnail: animation.getAsyncModel(),
            getVideoURL: {
                await FileService.getFilePath(for: animation.animation)
            }
        )
    }
}
