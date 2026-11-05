# Petal Path - Design System

Calm, simple, low-clutter coaching app. Big buttons, one main action per screen, generous whitespace.

## Color
Use ONLY these colors; no default violet or indigo, no flat neutral grey.
- Background (tinted near-white): #F4FBFC
- Surface (cards, sheets): #FFFFFF
- Surface alt (grouped rows): #EAF5F7
- Accent (bright cyan, large fills, icons, active states, big numerals only): #00C2E8
- Accent fill (buttons and chips with white labels, links): #00788F
- Accent tint (selected fills, badges): #DBF6FC
- Accent pressed: #006F85
- Support (soft pink, flower petals, charts, illustration only): #FF7AB6
- Support strong (chart series, thin lines): #FF529E
- Text primary: #0C1C1F, secondary: #4A5D61, tertiary: #66767A
- Border hairline: #D5E6E9, input and control border: #669C9F
- Status (text on its tint): success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5, info #00748A on #E0EFF2
- Hero gradient (only surface that carries white text): #00788F to #006F85

## Typography
- UI and body: Barlow Condensed. Display titles and numerals: Oswald.
- Display 32 / 700 / -0.02em, Title 20 / 600, Body 16 / 400, Label 14 / 500, Caption 13 / 500.
- Use only these 5 sizes. Minimum text 12px (13px chips and tags, 14px safety or legal text).

## Frame and spacing
- 393x852 mobile frame. Keep top ~59px and bottom ~34px safe areas clear.
- 8pt spacing scale (4, 8, 12, 16, 24, 32), 20px screen edge padding, generous vertical rhythm.

## Shape and elevation
- Radius: card 20, control 14, input 12, pill 999.
- Card shadow soft only: 0 1px 2px rgba(0,0,0,.04) + 0 8px 24px rgba(0,0,0,.06). No hard shadows.

## Icons
- One set only: rounded outline (Lucide style), 24px, 1.75 stroke. Never mix filled and outline.

## Controls (one spec, reused on every screen)
- Primary button: full-width pill, 56px tall, #00788F fill, white 16/600 label; pressed #006F85; disabled #D5E6E9 fill with #66767A label.
- Secondary button: pill, 1.5px #669C9F outline, #0C1C1F label.
- Input: 12px radius, 52px tall, #669C9F border; focus 2px #00788F ring; error #CE2020 border plus helper text.
- Card: white, 20px radius, soft shadow.
- Chip: pill, #DBF6FC fill, #00788F 13px label.
- Habit check button: 44px circle, outline #669C9F when open, filled #00788F with white check when done.

## Shared components
- Bottom tab bar (flat white, top hairline #D5E6E9), exactly 5 tabs in this order: Home (house icon), Learn (play-circle icon), Habits (check-circle icon), Progress (flower icon), Me (user icon). Active tab: icon and 13px label in #00788F with a small #DBF6FC pill behind the icon. Inactive: #4A5D61. Never rename, reorder, add or remove tabs.
- Header: 20px edge padding, screen title in Oswald left, at most one round icon button on the right.

## Focal element and gradient rules
- One bold focal element per screen (hero card, big numeral or the flower).
- Any surface with white text uses the hero gradient #00788F to #006F85 and nothing lighter. Soft cyan to pink blends are decoration only, never behind text. Tab bar stays flat. Pills on a gradient use a dark translucent fill, not white.

## Imagery
Imagery: real photography only; empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects. The progress flower is flat 2D vector shapes.

## Meaning of color
Red only for errors, destructive actions and truly urgent states. Non-urgent flags (quiet clients, month 5 alerts) use the warning color with an icon.

## Copy scope
Do not mention: diagnosis, ADHD test, medical advice, Telehealth, EHR, prescription. No invented integrations or person names beyond those listed in the brief (Maya Collins, Priya Shah, Hannah Lee, Zoe Martin). The product name is Petal Path.
