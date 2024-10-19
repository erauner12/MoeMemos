import SwiftUI
import WebKit

struct InAppBrowserView: UIViewRepresentable {
    let url: URL
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: InAppBrowserView

        init(_ parent: InAppBrowserView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Handle actions after navigation if needed
        }
    }

    var body: some View {
        VStack {
            WebViewContainer(webView: makeUIView(context: UIViewRepresentableContext(self)))
            HStack {
                Spacer()
                CloseButton(action: {
                    isPresented = false
                })
            }
            .padding()
        }
    }

    struct WebViewContainer: UIViewRepresentable {
        let webView: WKWebView

        func makeUIView(context: Context) -> WKWebView {
            webView
        }

        func updateUIView(_ view: WKWebView, context: Context) {}
    }

    struct CloseButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.secondary.opacity(0.7))
                    )
            }
        }
    }
}

struct InAppBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        InAppBrowserView(url: URL(string: "https://example.com")!, isPresented: .constant(true))
    }
}