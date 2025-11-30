newBirthDescriptor {
    type = "subclass",
    name = "Dummy",
    desc = "",
    talents_types = {
        ["cunning/conversion"] = { false, 0 }
    }
}

getBirthDescriptor("class", "Adventurer").descriptor_choices.subclass.Dummy = "disallow"