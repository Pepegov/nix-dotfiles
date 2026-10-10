---
name: figma-to-avalonia
description: Production workflow for implementing Figma designs as maintainable Avalonia UI using AXAML, MVVM, existing project resources, Figma MCP, Avalonia Build MCP, and Rider MCP.
compatibility: opencode
metadata:
  domain: avalonia-ui
  source: figma
  target: axaml
  architecture: mvvm
---

# Figma → Avalonia

Implement Figma designs as production-quality Avalonia UI.

The goal is **not** to mechanically reproduce pixels with ad-hoc markup. The goal is to translate the visual design, component structure, interaction states, and design tokens into idiomatic, maintainable Avalonia code that fits the existing application's architecture.

Use the available MCP servers deliberately:

* **Figma MCP** for design context, nodes, components, variables, styles, assets, and screenshots.
* **Avalonia Build MCP** for Avalonia-specific guidance and UI recreation/verification workflows.
* **Rider MCP** for semantic understanding of the existing .NET solution, symbols, usages, diagnostics, project structure, and IDE-assisted operations.
* **Shell/build tools** for commands such as `dotnet build`, `dotnet test`, and application launch.

---

# 1. Core Principles

## 1.1 Preserve the existing application architecture

Before writing UI code:

1. Inspect the repository structure.
2. Identify the target application/project.
3. Identify its UI architecture.
4. Identify existing Views, ViewModels, Styles, Themes, Resources, Controls, converters, behaviors, and design-system primitives.
5. Reuse existing abstractions whenever they satisfy the design.

Do not redesign the application's architecture merely to reproduce one screen.

Do not introduce a new framework, pattern, dependency, or UI library unless the existing project already uses it or there is a compelling technical reason.

---

## 1.2 Figma is the visual source of truth

Treat the referenced Figma design as the source of truth for:

* component hierarchy;
* dimensions;
* spacing;
* alignment;
* typography;
* colors;
* opacity;
* borders;
* corner radii;
* shadows/elevation;
* iconography;
* image assets;
* variants;
* interactive states;
* responsive behavior;
* repeated components.

Do not invent visual values when the information is available in Figma.

When an exact value cannot be recovered, choose the smallest reasonable approximation and keep it centralized so it can be adjusted easily.

---

## 1.3 Existing project code is the architectural source of truth

Figma describes what the UI should look like.

The existing codebase determines how that UI should be implemented.

Therefore:

* search before creating;
* reuse before duplicating;
* extend before replacing;
* preserve established naming and folder conventions;
* preserve MVVM boundaries;
* preserve existing resource and theme organization.

---

# 2. Required Workflow

Follow this workflow in order unless the user explicitly asks for a smaller task.

## Phase A — Understand the request

Determine:

* the Figma file;
* the exact frame/node being implemented;
* the target View or destination in the application;
* whether this is a new screen or modification of an existing one;
* whether desktop/mobile/responsive variants exist;
* whether the user expects interaction or only visual reproduction.

If the Figma URL is ambiguous, inspect the available Figma context and identify the most relevant frame.

Do not modify code during this phase.

---

# 3. Inspect Figma Before Coding

Use Figma MCP before implementing the UI.

Obtain as much of the following as available:

* design context;
* node hierarchy;
* component instances;
* component definitions;
* variants;
* variables;
* styles;
* dimensions;
* layout mode;
* spacing;
* constraints;
* typography;
* fills;
* strokes;
* effects;
* opacity;
* assets;
* screenshots.

For important screens, obtain a visual screenshot/reference as well as structured design data.

## Analyze the Figma structure

Build a mental mapping such as:

```text
Frame
├── Header
│   ├── Logo
│   ├── Navigation
│   └── ProfileMenu
├── MainContent
│   ├── Sidebar
│   └── Content
│       ├── Toolbar
│       └── List
└── Footer
```

Identify which nodes are:

* layout containers;
* reusable components;
* text;
* icons;
* decorative elements;
* interactive controls;
* content repeated through collections;
* stateful variants.

Do not create one Avalonia control for every decorative Figma layer.

---

# 4. Inspect the Existing Avalonia Project

Before adding files, inspect the project using Rider MCP and normal repository search.

Find:

* `.csproj`;
* existing Views;
* existing ViewModels;
* `Styles`;
* `Themes`;
* `Resources`;
* application-level resources;
* shared controls;
* custom controls;
* converters;
* behaviors;
* design tokens;
* brushes;
* typography definitions;
* spacing conventions;
* localization infrastructure;
* asset directories;
* navigation infrastructure.

Search for visually or semantically similar controls.

Examples:

```text
Search for:
- Button styles
- Card controls
- Navigation controls
- Form controls
- Dialogs
- Search boxes
- List items
- Empty states
- Loading indicators
- Icons
- Typography styles
```

Prefer an existing project component when it is close enough.

Only create a new component when:

1. no suitable existing component exists, or
2. the new component represents a meaningful reusable abstraction.

---

# 5. Build a Figma → Avalonia Mapping

Before implementation, map the design to concrete Avalonia concepts.

Example:

```text
Figma                    Avalonia
------------------------------------------------
Frame                    UserControl / Window
Auto Layout              Grid / StackPanel / DockPanel
Component                UserControl / ContentControl
Component Variant        StyledProperty / DataTemplate / selector
Text                     TextBlock
Input                    TextBox
Button                   Button
Card                     Border
Repeated collection      ItemsControl / ListBox
Image                    Image
Icon                     PathIcon / Image
Overlay                  Panel / Popup / Flyout
Modal                    Window / DialogHost if project uses one
Divider                  Border
```

This is guidance, not a rigid one-to-one translation.

Choose the control that best matches both the visual behavior and the existing application architecture.

---

# 6. Avalonia-Specific Rules

Generate **Avalonia XAML / AXAML**, never WPF XAML.

Do not use:

```text
System.Windows.*
WPF-only APIs
WPF-only attached properties
WPF-specific converters
WPF Grid APIs
WPF-specific Window APIs
```

Prefer idiomatic Avalonia constructs.

Examples include:

```xml
<UserControl>
<Grid>
<StackPanel>
<DockPanel>
<Border>
<ScrollViewer>
<ContentControl>
<ItemsControl>
<ListBox>
<TextBlock>
<TextBox>
<Button>
<ToggleButton>
<CheckBox>
<ComboBox>
<Image>
<PathIcon>
</UserControl>
```

Use Avalonia property syntax and styling conventions appropriate to the project's Avalonia version.

Do not assume WPF compatibility.

---

# 7. Layout Rules

Translate Figma Auto Layout into actual layout behavior.

## Prefer Grid when

* there are explicit columns or rows;
* alignment between independent regions matters;
* several controls must line up across sections.

## Prefer StackPanel when

* elements form a simple linear sequence;
* content naturally grows in one direction.

## Prefer DockPanel when

* content is anchored to edges;
* there is a clear header/content/footer or side-content relationship.

## Use flexible sizing

Prefer:

```xml
<Grid ColumnDefinitions="Auto,*">
```

over unnecessary fixed widths.

Use fixed dimensions only when the design or product requirements genuinely require them.

## Avoid coordinate-based reconstruction

Do not reproduce a UI by stacking controls with arbitrary margins merely to match one screenshot.

Bad:

```xml
<Button Margin="183,47,0,0" />
```

when the correct solution is structural layout.

---

# 8. Spacing and Sizing

Extract meaningful spacing values from the design.

When repeated values occur, determine whether they represent design tokens.

Prefer shared resources for repeated values when the project already has a design-token system.

Examples:

```text
SpacingXS
SpacingSM
SpacingMD
SpacingLG
CornerRadiusSM
CornerRadiusMD
ControlHeight
```

Do not introduce a token system into a project that does not use one merely for one screen.

Follow the project's existing conventions.

---

# 9. Typography

Preserve:

* font family;
* font size;
* weight;
* line height where supported;
* letter spacing where supported;
* alignment;
* wrapping;
* truncation;
* maximum lines.

Do not replace a project-specific typography style with arbitrary local properties if an equivalent existing style exists.

Prefer existing typography resources and styles.

If a Figma font is unavailable, use the project's configured fallback and document the deviation in the implementation summary.

---

# 10. Colors, Brushes, Borders and Effects

Prefer existing project resources.

For repeated colors:

```xml
Background="{DynamicResource SomeBrush}"
Foreground="{DynamicResource SomeBrush}"
```

when the project already follows this convention.

Do not duplicate the same literal color across many controls.

Do not create dozens of near-identical brushes merely to match small Figma variations.

For borders:

* reproduce thickness;
* reproduce brush/color;
* reproduce radius;
* reproduce relevant states.

For shadows/elevation:

* use the closest supported Avalonia mechanism;
* do not fake shadows with unnecessary bitmap assets or nested borders unless the design requires it.

---

# 11. Components

Treat repeated Figma components as reusable UI concepts.

If a Figma component appears multiple times:

1. identify its semantic role;
2. search the codebase for an existing equivalent;
3. reuse it if appropriate;
4. otherwise create a reusable Avalonia component.

Do not duplicate the same AXAML structure throughout a View.

Prefer:

```text
Views/
Controls/
Styles/
Themes/
```

according to the existing project structure.

Expose only meaningful parameters.

Avoid creating a component with twenty properties simply to mirror every Figma layer.

---

# 12. Component Variants and States

Map Figma variants to Avalonia state mechanisms.

Possible implementations include:

* styles;
* selectors;
* pseudo-classes;
* styled properties;
* data templates;
* visual states where appropriate;
* MVVM state.

Examples of states:

```text
Default
Hover
Pressed
Focused
Disabled
Selected
Checked
Loading
Error
Empty
Expanded
Collapsed
```

Do not implement only the default state when Figma clearly defines interactive states.

Do not encode state with arbitrary boolean properties when the project already has established Avalonia patterns for the same behavior.

---

# 13. MVVM and Behavior

Keep view logic out of code-behind unless it is genuinely view-specific.

Prefer:

```text
View
    ↓
ViewModel
    ↓
Commands / State
```

Use bindings for application state.

For buttons and interactive elements, prefer existing command infrastructure.

Do not invent new navigation/event systems.

Search for existing ViewModel patterns before creating one.

---

# 14. Assets

Before creating or importing assets:

1. inspect existing project assets;
2. check whether the icon/image already exists;
3. inspect Figma asset metadata;
4. reuse existing assets whenever possible.

Do not create placeholder assets when the real asset is available.

Do not embed large base64 assets into AXAML.

Use the project's established asset/resource conventions.

For icons:

* prefer the project's existing icon system;
* use `PathIcon` or equivalent when appropriate;
* avoid rasterizing vector icons unnecessarily.

---

# 15. Responsive and Window Behavior

Do not assume that Figma's desktop dimensions are the application's fixed window size.

Determine whether the design implies:

* flexible width;
* minimum width;
* maximum width;
* sidebar collapse;
* content scrolling;
* adaptive navigation;
* breakpoint-like behavior.

Implement the behavior required by the application, not just the dimensions of one exported screenshot.

---

# 16. Accessibility and Usability

Preserve semantic meaning.

Where the existing project supports it:

* provide accessible names;
* ensure keyboard interaction;
* preserve focus behavior;
* ensure disabled/selected states are clear;
* avoid relying on color alone;
* ensure text remains readable.

Do not sacrifice interaction quality merely to match a screenshot.

---

# 17. Implementation Order

Implement in this order:

1. page/root layout;
2. major regions;
3. reusable components;
4. typography;
5. spacing and sizing;
6. colors and surfaces;
7. controls and states;
8. icons/assets;
9. bindings and commands;
10. responsive behavior;
11. final visual corrections.

This reduces rework.

---

# 18. Keep Changes Scoped

Modify only files required for the requested UI.

Do not:

* reformat unrelated files;
* rename unrelated classes;
* restructure the solution;
* upgrade dependencies;
* change build configuration;
* modify global themes unnecessarily;
* delete old components without evidence they are obsolete.

If a shared style must change, inspect its usages first because a shared change can affect the entire application.

---

# 19. Build Early

After the first meaningful implementation:

```bash
dotnet build
```

Do not wait until the entire UI is finished.

Fix:

* XAML parse errors;
* binding errors;
* missing resources;
* invalid properties;
* namespace issues;
* missing assets;
* C# compilation errors.

Use Rider MCP to inspect diagnostics and existing symbols where useful.

---

# 20. Use Rider MCP for Semantic Work

When available, prefer Rider's semantic tools over blind text manipulation.

Use Rider MCP to:

* inspect solution structure;
* find symbols;
* locate existing components;
* find usages;
* inspect implementations;
* inspect diagnostics;
* understand dependencies;
* run configurations when appropriate.

Before creating a new class/control/style, search for an existing implementation.

If a tool is exposed through Rider's router-only mechanism, use the appropriate router path rather than assuming the tool is directly listed.

---

# 21. Visual Verification

For visual tasks, a successful build is not sufficient.

After implementation:

1. run the application or attach to the relevant preview;
2. obtain a screenshot/reference;
3. compare against the Figma design;
4. identify the largest visual discrepancies;
5. correct them;
6. repeat.

Avalonia Build MCP's `recreate-ui` workflow is intended for iterative UI recreation and can use DevTools for preview/screenshots when that integration is available.

Prioritize corrections in this order:

```text
1. Overall structure
2. Major dimensions
3. Alignment
4. Spacing
5. Typography
6. Colors
7. Borders/radii
8. Icons/assets
9. Shadows/effects
10. Small pixel-level differences
```

Do not waste time perfecting a 2px border when the main column is the wrong width.

---

# 22. Visual Comparison Rules

When comparing against Figma, explicitly inspect:

## Geometry

* viewport size;
* main content width;
* panel widths;
* heights;
* margins;
* padding;
* gaps;
* alignment.

## Typography

* font;
* font size;
* weight;
* line height;
* wrapping;
* baseline/alignment.

## Visuals

* backgrounds;
* fills;
* opacity;
* borders;
* radius;
* shadows;
* icons;
* images.

## Interaction

* hover;
* pressed;
* focused;
* selected;
* disabled;
* validation;
* loading.

---

# 23. Do Not Overfit to Screenshots

A screenshot is evidence of visual output.

It is not permission to implement the UI using hacks.

Avoid:

* arbitrary absolute positioning;
* excessive nested Borders used as spacers;
* transparent controls used solely to create geometry;
* duplicated layers with magic margins;
* canvas-based UI for ordinary application screens;
* hard-coded text widths that break localization;
* hard-coded heights that clip dynamic content.

Prefer semantic layout.

---

# 24. Error Handling

When something cannot be reproduced exactly, do not silently invent behavior.

Record the limitation internally and choose the closest robust implementation.

Examples:

* Figma uses a font unavailable in the application.
* Figma uses an effect not directly available in the current Avalonia version.
* An exported asset is unavailable.
* A responsive behavior is ambiguous.

Choose the closest supported solution that preserves maintainability.

---

# 25. Completion Criteria

Consider the task complete only when all applicable conditions are satisfied:

* [ ] Correct Figma frame was analyzed.
* [ ] Existing Avalonia architecture was inspected.
* [ ] Existing reusable components/styles were searched.
* [ ] No unnecessary duplicate components were introduced.
* [ ] AXAML uses Avalonia APIs rather than WPF APIs.
* [ ] Major layout geometry matches the design.
* [ ] Typography is reasonably matched.
* [ ] Colors and surfaces are matched.
* [ ] Components/states represented in the design are implemented.
* [ ] Required bindings/commands are connected.
* [ ] Assets are handled correctly.
* [ ] `dotnet build` succeeds.
* [ ] Relevant diagnostics were checked.
* [ ] UI was visually verified when tooling permits.
* [ ] Major visual discrepancies were corrected.
* [ ] Unrelated project files were not modified.

---

# 26. Final Response Format

After implementation, report:

## Implemented

Describe the View/component(s) created or modified.

## Reused

List important existing project components/styles/resources reused.

## Verification

Report:

* build result;
* tests, if relevant;
* visual verification status.

## Deviations

List only meaningful deviations from Figma and explain why.

Do not claim visual verification if no screenshot/preview comparison was actually performed.

---

# 27. Important Tool Discipline

Do not call every MCP tool merely because it is available.

Use the smallest set of tools needed to accomplish the task.

Typical tool sequence:

```text
Figma MCP
    ↓
analyze design
    ↓
Rider MCP
    ↓
inspect project
    ↓
implement AXAML/C#
    ↓
dotnet build
    ↓
Rider diagnostics
    ↓
Avalonia Build MCP / DevTools
    ↓
visual verification
    ↓
iterate
```

For an existing project, never start by blindly generating a new View.

First understand the project.

For a simple design change, do not invoke a full reconstruction workflow unnecessarily.

For a full-screen reproduction, use the complete workflow.

---

# 28. Quality Bar

The output must be production code, not a demo.

Prefer:

```text
maintainability
+
correct Avalonia architecture
+
reuse
+
visual fidelity
+
clear state handling
```

over:

```text
pixel imitation
+
magic numbers
+
duplicated styles
+
one-off hacks
```

When visual fidelity and maintainability conflict, choose the smallest architectural compromise that preserves both, and document the compromise.

Never use screenshot hacks as a substitute for understanding the Figma layout.
