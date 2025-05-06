//
//  DashboardView.swift
//  SwiftSample
//
//  Created by Nelson Maia Matias on 15/04/2025.
//

import SwiftUI
import WebKit
import Auth0


struct DashboardView: View {
    let user: User
    private let advantageNumber = "AO \(Int.random(in: 100...999)) \(Int.random(in: 100...999)) \(Int.random(in: 100...999))"
    @State private var openURL = false
    @State private var useSSO = true


    var body: some View {
        ZStack(alignment: .top) {
            Image("ScenicBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hazel Nutt")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Auziros Advantage® member")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))

                    Text("Member ID: \(advantageNumber)")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))

                    Text("Available miles: \(Int.random(in: 8000...18000))")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.6))
                
                .padding(.horizontal)
                .padding(.top, 60)

                Spacer()
            }
            .frame(maxWidth:  UIScreen.main.bounds.width, alignment: .leading) // ✅ THIS is what pins it left




            BottomSheetView {
                VStack(spacing: 0) {
                    // Top blue buttons
                    HStack(spacing: 32) {
                        DashboardButton(icon: "clock", label: "Flight status")
                        DashboardButton(icon: "magnifyingglass", label: "Find trip")
                        DashboardButton(icon: "airplane", label: "Book flights")
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    .frame(maxWidth: UIScreen.main.bounds.width)

                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        // First section
                        VStack(spacing: 0) {
                            DrawerListItem(title: "Track your bags")
                            DrawerListItem(title: "Wi-Fi and free entertainment")
                            DrawerListItem(title: "Airport maps")
                            DrawerListItem(title: "Auziros Club® locations")
                            
                            DrawerListItem(title: "Book Flight with Auziros Club®") {
                                if useSSO {
                                    openBookingWebView()
                                } else {
                                    openBookingWithoutSSO()
                                }
                            }


                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        
                       

                        // Second section
                        VStack(spacing: 0) {
                            DrawerListItem(title: "General information")
                            DrawerListItem(title: "Privacy policy")
                            DrawerListItem(title: "Contact Auziros")
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        
                       

                        Toggle(isOn: $useSSO) {
                            Text("Use Native to Web SSO")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)

                        DrawerListItem(title: "Log out", isDestructive: true)
                            .padding(.horizontal)
                            .padding(.top)

                        
                    }

                    
                }
                .background(Color(hex: "#F6F6F6"))
                .padding(.horizontal, 12)
                .frame(maxWidth: UIScreen.main.bounds.width)

            }
        }
    }
}


func openBookingWebView() {
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    credentialsManager.credentials { result in
        switch result {
        case .success(let credentials):
            let refreshToken = credentials.refreshToken ?? ""
            Auth0
                .authentication()
                .ssoExchange(withRefreshToken: refreshToken)
                .start { result in
                    switch result {
                    case .success(let ssoCredentials):
                        
                        
                        print("ssoCredentials \(ssoCredentials)")
                        print("ssoCredentials \(ssoCredentials.sessionTransferToken)")
                        
                        DispatchQueue.main.async {
                            let cookie = HTTPCookie(properties: [
                                .domain: "nelson.jp.auth0.com",
                                .path: "/",
                                .name: "auth0_session_transfer_token",
                                .value: ssoCredentials.sessionTransferToken,
                                .expires: ssoCredentials.expiresIn,
                                .secure: true
                            ])!

                            let webView = WKWebView()
                            let store = webView.configuration.websiteDataStore.httpCookieStore
                            store.setCookie(cookie) {
                                let url = URL(string: "https://auziros-club.vercel.app")!
                                let request = URLRequest(url: url)
                                webView.load(request)

                                let vc = UIViewController()
                                vc.view = webView
                                UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
                            }
                        }

                    case .failure(let error):
                        print("Failed to get SSO token: \(error)")
                    }
                }
        case .failure(let error):
            print("Error loading credentials: \(error)")
        }
    }
}

func openBookingWithoutSSO() {
    DispatchQueue.main.async {
        let url = URL(string: "https://auziros-club.vercel.app")!
        let request = URLRequest(url: url)
        let webView = WKWebView()
        webView.load(request)

        let vc = UIViewController()
        vc.view = webView
        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
    }
}




struct BottomSheetView<Content: View>: View {
    @GestureState private var dragOffset = CGFloat.zero
    @State private var offsetY: CGFloat

    let minHeight: CGFloat = 120
    let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.55
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        _offsetY = State(initialValue: UIScreen.main.bounds.height - minHeight - 120)
    }
    
    private var collapsedOffset: CGFloat {
            maxHeight - minHeight - 80
        }

        private var expandedOffset: CGFloat {
            maxHeight * 0.8
        }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

         
                content()
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                    
         
        }
        .frame(maxWidth: .infinity)
        .frame(height: maxHeight, alignment: .top)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 10)
        .offset(y: offsetY + dragOffset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                                let snap = maxHeight * 0.3
                                withAnimation(.interactiveSpring()) {
                                    if value.translation.height > snap {
                                        offsetY = maxHeight - minHeight - 60
                                    } else {
                                        offsetY = maxHeight * 0.8
                                    }
                                }
                            }
        )
    }
}




struct DashboardButton: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color(hex: "#0051BA"))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                )

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
        }
    }
}



struct DrawerListItem: View {
    let title: String
    var isDestructive: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .foregroundColor(isDestructive ? .red : Color(hex: "#0051BA"))
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)

                Divider()
                    .padding(.leading, 16)
            }
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle()) // removes default button styling
    }
}





var body: some View {
    VStack(spacing: 0) {
        // Top blue buttons
        HStack(spacing: 32) {
            DashboardButton(icon: "clock", label: "Flight status")
            DashboardButton(icon: "magnifyingglass", label: "Find trip")
            DashboardButton(icon: "airplane", label: "Book flights")
        }
        .padding(.top, 16)
        .padding(.bottom, 8)

        Divider()

        VStack(spacing: 0) {
            DrawerListItem(title: "Track your bags")
            DrawerListItem(title: "Wi-Fi and free entertainment")
            DrawerListItem(title: "Airport maps")
            DrawerListItem(title: "Admirals Club® locations")
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)

        VStack(spacing: 0) {
            DrawerListItem(title: "General information")
            DrawerListItem(title: "Privacy policy")
            DrawerListItem(title: "Contact Auziros")
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding([.horizontal, .top])

        DrawerListItem(title: "Log out", isDestructive: true)
            .padding(.horizontal)
            .padding(.top)
    }
    .background(Color(hex: "#F6F6F6"))
    .cornerRadius(24)
}

extension Color {
    init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

import SwiftUI
import WebKit

struct WebViewView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct WebScreen: View {
    let url: URL
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            WebViewView(url: url)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}





