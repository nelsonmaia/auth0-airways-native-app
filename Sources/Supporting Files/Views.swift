import SwiftUI

struct HeroView: View {
    private let tracking: CGFloat = -1.5

    let loginAction: () -> Void
    let guestAction: () -> Void
    let joinAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo + Icon
            HStack(spacing: 16) {
                Image("auth0-airlines-logo-transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 98, height: 98)

            }
            .frame(maxWidth: .infinity) // ✅ Let it expand
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                Button("Log In", action: loginAction)
                    .buttonStyle(FullWidthButtonStyle())

                Button("Continue as Guest", action: guestAction)
                    .buttonStyle(FullWidthButtonStyle())

                Button("Join Auziros Advantage Program", action: joinAction)
                    .buttonStyle(FullWidthButtonStyle(variant: .link))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity) // ✅ Let the outer stack expand too
        .padding()

    }
}



struct ProfileHeader: View {
    @State var picture: String

    private let size: CGFloat = 100

    var body: some View {
    #if os(iOS)
        AsyncImage(url: URL(string: picture), content: { image in
            image.resizable()
        }, placeholder: {
            Color.clear
        })
        .frame(width: self.size, height: self.size)
        .clipShape(Circle())
        .padding(.bottom, 24)
    #else
        Text("Profile")
    #endif
    }
}

struct ProfileCell: View {
    @State var key: String
    @State var value: String

    private let size: CGFloat = 14

    var body: some View {
        HStack {
            Text(key)
                .font(.system(size: self.size, weight: .semibold))
            Spacer()
            Text(value)
                .font(.system(size: self.size, weight: .regular))
            #if os(iOS)
                .foregroundColor(Color("Grey"))
            #endif
        }
    #if os(iOS)
        .listRowBackground(Color.white)
    #endif
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    private let padding: CGFloat = 8

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .padding(.init(top: self.padding,
                           leading: self.padding * 6,
                           bottom: self.padding,
                           trailing: self.padding * 6))
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

enum ButtonVariant {
    case filled
    case outlined
    case link
}

struct FullWidthButtonStyle: ButtonStyle {
    var variant: ButtonVariant = .filled

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor(isPressed: isPressed))
            .foregroundColor(foregroundColor())
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func backgroundColor(isPressed: Bool) -> some View {
        switch variant {
        case .filled:
            return Color.black.opacity(isPressed ? 0.8 : 1.0)
        case .outlined:
            return Color.gray.opacity(0.1)
        case .link:
            return Color.clear
        }
    }

    private func foregroundColor() -> Color {
        switch variant {
        case .filled: return .white
        case .outlined: return .black
        case .link: return .blue
        }
    }
}


