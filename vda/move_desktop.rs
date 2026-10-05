
// --- Added for DeskTabs (https://github.com/paehtz/DeskTabs) -----------------
// Appended to dll/src/lib.rs of Ciantic/VirtualDesktopAccessor by the workflow
// .github/workflows/build-dll.yml. winvd::move_desktop exists since PR #114
// (October 2026), the DLL did not export it yet.

/// Move (reorder) desktop `desktop_number` to position `new_index` (both 0-based).
/// Returns 1 on success, -1 on failure.
#[no_mangle]
pub extern "C" fn MoveDesktop(desktop_number: i32, new_index: i32) -> i32 {
    if desktop_number < 0 || new_index < 0 {
        return -1;
    }
    move_desktop(desktop_number, new_index as u32).map_or(-1, |_| 1)
}
