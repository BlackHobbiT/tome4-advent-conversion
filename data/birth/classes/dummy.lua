newBirthDescriptor {
    type = "subclass",
    name = "Dummy",
    desc = "",
    not_on_random_boss = true,
    talents_types = {
        ["cunning/conversion"] = { false, 0 }
    }
}

getBirthDescriptor("class", "Adventurer").descriptor_choices.subclass.Dummy = "disallow"