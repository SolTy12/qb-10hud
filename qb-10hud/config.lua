Config = {}

Config.OpenKey = 'F10' -- כאן אפשר לשנות את המקש איתו פותחים את ההגדרות

-- =========================
-- CAVE CONFIGURATION
-- =========================
Config.Cave = {
    CooldownTime = 5000, -- 5 seconds cooldown in milliseconds
    RequiredItem = 'mokdan', -- The item required to open the cave
    RequireItemForUI = true, -- Require mokdan item to open UI settings
    NotificationMessages = {
        success = 'המערה נפתחה בהצלחה!',
        error = 'אתה צריך מוקדן כדי לפתוח את המערה!',
        cooldown = 'אתה חייב לחכות לפני שתוכל לפתוח את המערה שוב!',
        noitem = 'אתה צריך מוקדן כדי לפתוח את המערכת!'
    }
}

Config.Jobs = {
    police = true,
    sheriff = true,
}

-- כאן תוכלו לשנות את המראה של המחלקות
Config.DepartmentsByGrade = {
    [0] = 'אקדמאים',
    [1] = 'סיור משטרתי',
    [2] = 'יס״מ',
    [3] = 'ימ״מ',
    [4] = 'קצינים',
    [5] = 'פיקוד בכיר',
    [6] = 'מפכ״ל'
}


-- כל הזכויות שמורות לסול