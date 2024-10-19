import SwiftUI
import WebKit

struct InAppBrowserView: UIViewRepresentable {
    let url: URL
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Enable cookie sharing with Safari
        if #available(iOS 11.0, *) {
            webView.configuration.websiteDataStore = WKWebsiteDataStore.default()
        }
        
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
        
        private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated {
                if let url = navigationAction.request.url, url.host != self.parent.url.host {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }
    }
}

struct WebViewContainer: View {
    let url: URL
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            InAppBrowserView(url: url, isPresented: $isPresented)
            HStack {
                Spacer()
                CloseButton(action: {
                    isPresented = false
                })
            }
            .padding()
        }
    }
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

struct InAppBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        WebViewContainer(url: URL(string: "https://example.com")!, isPresented: .constant(true))
    }
}
