import SwiftUI

struct ResourcesSectionDropdown<Content: View>: View {
    let title: String
    let content: Content
    
    @State private var isExpanded = false
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(Font(BMFont.bold(25)))
                        .foregroundStyle(Color(uiColor: BMColor.primaryText))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .fontWeight(.heavy)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? 45 : 0))
                }
                .padding()
                .background(Color(uiColor: BMColor.cardBackground))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                content
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
                    .background(Color(uiColor: BMColor.cardBackground))
            }
        }
        .background(Color(uiColor: BMColor.cardBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}


// MARK: - Preview

struct ResourcesSectionDropdown_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesSectionDropdown(title: "Sample") {
            VStack(alignment: .leading) {
                Text("Content")
                Text("More")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 