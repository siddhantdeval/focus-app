import SwiftUI
import FocusCore

struct TaskRowView: View {
    let task: FocusTask
    let isSelected: Bool
    let onToggleComplete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: TWSpacing.p(4)) {
            // Custom Checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .font(TWFont.xl)
                    .foregroundColor(task.isCompleted ? Color.slate300 : Color.primaryBackground)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: TWSpacing.p(1)) {
                Text(task.title)
                    .font(TWFont.sm.weight(.semibold))
                    .foregroundColor(task.isCompleted ? Color.slate400 : Color.primaryBackground)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)
                
                // Metadata row (Due date, subtasks)
                HStack(spacing: TWSpacing.p(3)) {
                    HStack(spacing: TWSpacing.p(1)) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text("Today")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Color.slate400)
                    
                    HStack(spacing: TWSpacing.p(1)) {
                        Image(systemName: "checklist")
                            .font(.system(size: 11))
                        Text("2/5")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Color.slate400)
                }
            }
            
            Spacer()
            
            // Notification Bell (Visible on hover or if selected)
            Image(systemName: "bell")
                .font(TWFont.base)
                .foregroundColor(Color.slate300)
                .opacity(isHovered || isSelected ? 1.0 : 0.0)
                .onTapGesture {
                    print("Toggle notification for \(task.id)")
                }
        }
        .padding(.vertical, TWSpacing.p(3))
        .padding(.horizontal, TWSpacing.p(4))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.slate50 : (isHovered ? Color.slate50.opacity(0.5) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.slate200 : Color.clear, lineWidth: 1)
        )
        // Ensure the entire row area captures hover, not just the text
        .contentShape(Rectangle())
        // Tracking hover state for the row
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                self.isHovered = hovering
            }
        }
    }
}
