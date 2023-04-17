const ValidFonts = {  // 2 is a numbers font, 3 is a symbols font in both games
    'fivem': {
        'default': 0,  // 5 is the same
        'italics': 1,
        'compact': 4,  // 6 is the same
        'vice': 7,
    },
    'redm': {
        'default': 0,
        'bold': 1,
        'transparent': 4,
        'fancy': 6
    }
};

const DefaultSettings = {
    'precision': 2, // fractional precision
    'fade_speed': 5,
    'ignore_vehicles': false,
    'dynamic_fade': true,
    'local_damage': true,
    'writhe_speak': true,  // setting not yet implemented
    // 'offset_mode': 'float',
    'offset_intensity': 50,
    // 'offset_mode_fly_speed': 0.0025,
    // 'offset_mode_fly_direction': nil,
    'render_font': ValidFonts['default'],  // setting not yet implemented in UI, /testfont <number (0, 1, 4, 7)> can be used but it doesn't save.
    'color': {  // settings not yet implemented
        'damage_vehicle_ding': [154, 154, 154],
        'damage_entity': [224, 50, 50],
        'damage_armor': [93, 182, 229],
        'entity_writhe': [169, 0, 0],
    }
};

let Settings = DefaultSettings;

const DebugFlags = {
    'prefer_pvp': true
}