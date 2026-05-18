# KeepUp content safety signal registry.
#
# Slur detection uses the better-profanity library (word list lives inside the
# package — not in this codebase). Leet-speak normalization runs in main.py
# before the library check, so f4g / r3tard / n1gger are all caught.
#
# Grooming patterns are split into two dicts by relationship context:
#
#   GROOMING_ANY          — concerning regardless of who is sending. Even a
#                           peer saying "our little secret" to another student
#                           is a red flag.
#
#   GROOMING_ADULT_TO_MINOR — normal or neutral between peers, but a red flag
#                           when the sender is a coach, admin, or other adult
#                           and the recipient is a student. "Are you seeing
#                           anyone" is teen small talk; from a coach it is a
#                           boundary violation.
#
# Both dicts are injected into Gemma's system prompt with their relationship
# context labeled so Gemma applies the right threshold based on sender_role.

GROOMING_ANY: dict[str, list[str]] = {
    # Instructing a minor to hide something from trusted adults — a red flag
    # regardless of whether it comes from a peer or an authority figure.
    "secrecy_from_adults": [
        "our little secret",
        "don't tell your parents",
        "don't tell your coach",
        "don't tell anyone",
        "don't tell the others",
        "keep this between us",
        "keep this to yourself",
        "promise you won't tell",
    ],

    # Physical isolation combined with secrecy — unambiguous warning sign from
    # any sender, including peers. "Meet me alone" + any "don't tell" phrasing
    # together constitute a grooming pattern regardless of relationship.
    "isolation_with_secrecy": [
        "meet me alone",
        "meet me privately",
        "meet me in private",
        "come alone",
        "don't bring anyone",
        "don't tell the other",
        "just the two of us",
    ],

    # Maturity/age commentary that frames the minor as older than they are.
    "age_commentary": [
        "you're mature for your age",
        "you seem older than you are",
        "you look older than your age",
    ],

    # Explicit image solicitation — unambiguous regardless of relationship.
    "explicit_solicitation": [
        "send nudes",
        "send me something explicit",
    ],

    # Conditional gifts with an implied expectation — the "if you" or
    # transactional framing is the signal, not the gift itself.
    "conditional_luring": [
        "I have something for you if you",
        "I'll make it worth your while",
        "there's something in it for you if",
    ],
}


GROOMING_ADULT_TO_MINOR: dict[str, list[str]] = {
    # Moving a student off the monitored platform onto a private channel.
    # Coaches sharing contact info for team logistics is normal; these phrases
    # imply private, off-record, one-on-one contact.
    "platform_migration": [
        "text me instead",
        "add me on snapchat",
        "DM me on instagram",
        "here's my personal number",
        "let's talk off the app",
        "let's move to text",
        "reach me at my personal",
    ],

    # Physical isolation. "Meet me after practice" and "let's work one-on-one"
    # are routine — these phrases combine isolation with secrecy or exclusion.
    "isolation_tactics": [
        "meet me alone",
        "don't bring anyone",
        "come to my place",
        "meet me privately",
        "don't tell the others you're coming",
    ],

    # Sexualized appearance comments. Between peers these could be compliments;
    # from a coach or adult to a student they are inappropriate.
    "appearance_comments": [
        "you have such a great body",
        "you're so attractive",
        "you're so beautiful",
        "your body is incredible",
        "you look amazing in that outfit",
    ],

    # Personal photo requests. "Send me a video of your stroke" is coaching;
    # these are phrased as personal photo requests to the individual.
    "photo_requests": [
        "send me a photo",
        "send me a pic",
        "send me pictures",
        "can you send a photo",
        "show me a picture of yourself",
    ],

    # Age-minimization — designed to make the student discount the age gap.
    "age_minimization": [
        "age is just a number",
        "age doesn't matter between us",
        "you're so mature it doesn't matter",
        "you act way older than you are",
        "I forget how young you are",
    ],

    # Romantic or sexual probing. Normal peer conversation — not appropriate
    # from a coach, AD, or any adult in a position of authority over the student.
    "romantic_probing": [
        "are you seeing anyone",
        "do you have a boyfriend",
        "do you have a girlfriend",
        "do you like older people",
        "have you ever been with someone older",
        "what do you look for in a partner",
        "would you ever date someone my age",
    ],

    # Gift-based luring — inappropriate from an adult to a minor even without
    # an explicit conditional.
    "gift_luring": [
        "I'll buy you whatever you want",
        "I'll get you anything you need",
        "I can take care of you",
    ],
}
