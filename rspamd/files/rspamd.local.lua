config['regexp']['SUBJECT_SPAM_KEYWORDS'] = {
        re = 'Subject=/(Nitril|Hochwertiger Sex|Matsato|PEEK|Küchenmesser|Derila|coin|Bluthochdruck|ewichtsverlust|Gelenkschmerz|Alcozar|Harnproblem|Keto|Papillome|Clean Scrubber|Vibe|schnarchfrei|Toilettenreiniger|Vitalprodukt|Weltneuheit|Dünnes Pflaster|Erektion|Entgiftungsprogramm|Nuubu|Matsato|Matsano|Körperhaltung|Fußschmerzen|Nagelpilz|Macha Slim|Toilet Cleaner)/',
        score = 3,
        description = 'Keywords that often occur in spam mail subjects.',
        group = 'HEADER_FILTERS'
}

config['regexp']['FROM_SPAM_KEYWORDS'] = {
        re = 'FROM=/(INFLATEX|Ocuvit|Hondro|Hiloi|E-Energy|Ibutamoren|Top Device|Pulsero|Matsato|Artrolux|MaxVibe|Gesunde Ohren|Casino|Hondofrost|Ostoflex|Dr Derm|ABSlim|Derila|Gelenkgesundheit|Gelenke|Keto|Nuubu|Alcozar|EMURA|Prostatitis|Fungent|Enence|Removio|Synoshi|Huusk|Micardium|Lastic|Cysti|Glucoslim|Trichomist|Glamilips|Akusoli|Achtung|Lifehack|Wichtig|Fizz|CookingStyle|Purisaki|Detox|Patches|Erexol|Dessert Knive|Matsato|Matsano|Wix.com|Adectal|NuroClean|Sparkling Clean|Balancio|Wuffy|NailRevive|Macha Slim)/',
        score = 3,
        description = 'Keywords that often occur in From name.',
        group = 'HEADER_FILTERS'
}

config['regexp']['IS_SUBDOMAIN'] = {
        re = 'FROM=/@(.*)[.]+[a-z]+[.]+[a-z>]+$/H',
        score = 0.3,
        description = 'Mail is coming from a subdomain.',
        group = 'HEADER_FILTERS'
}

config['regexp']['BAD_TLD'] = {
        re = 'From=/\\.(ar|autos|bet|biz|beauty|bet|br|business|cl|cn|co|cr|coupons|deals|directory|gold|hair|in|lol|makeup|mg|moscow|mx|no|nu|ru|pro|py|sex|shop|store|su|tc|tr|yachts|zw|taxi|pics|pe|sale|my|team|qpon|club|ma|diy|monster|homes|living|help|vip|discount|day|mom|site|baby|cyou|quest|auction)[>]?$/H',
        score = 3,
        description = 'Mail is coming from a TLD that is often associated with Spam.',
        group = 'HEADER_FILTERS'
}

config['regexp']['UNIMPORTANT_TLD'] = {
        re = 'From=/([\\w.%+-]+@(?!.*\\b(?:de|eu|com|net|org)\\b)[A-Za-z0-9.-]+\\.[A-Za-z]{2,})>?$/',
        score = 0.5,
        description = 'Mail is not coming from an known (important) TLD.',
        group = 'HEADER_FILTERS'
}

config['regexp']['21_OR_MORE_RECIPIENTS'] = {
        re = 'TO=/(?:[^,]*,){21}/',
        score = 1,
        description = 'More than 20 recipients.',
        group = 'HEADER_FILTERS'
}

config['regexp']['51_OR_MORE_RECIPIENTS'] = {
        re = 'TO=/(?:[^,]*,){51}/',
        score = 2,
        description = 'More than 50 recipients.',
        group = 'HEADER_FILTERS'
}

config['regexp']['101_OR_MORE_RECIPIENTS'] = {
        re = 'TO=/(?:[^,]*,){101}/',
        score = 3,
        description = 'More than 100 recipients.',
        group = 'HEADER_FILTERS'
}

config['regexp']['151_OR_MORE_RECIPIENTS'] = {
        re = 'TO=/(?:[^,]*,){151}/',
        score = 4,
        description = 'More than 150 recipients.',
        group = 'HEADER_FILTERS'
}

config['regexp']['201_OR_MORE_RECIPIENTS'] = {
        re = 'TO=/(?:[^,]*,){201}/',
        score = 5,
        description = 'More than 200 recipients.',
        group = 'HEADER_FILTERS'
}

rspamd_config.BAD_TLD_AND_SUBDOMAIN = {
  callback = function(task)
    if task:has_symbol('IS_SUBDOMAIN') and task:has_symbol('BAD_TLD') then
      return true
    end
    return false
  end,
  score = 4.0,
  description = "Fired when both IS_SUBDOMAIN and BAD_TLD are present",
  group = "custom"
}
rspamd_config:register_dependency('BAD_TLD_AND_SUBDOMAIN', 'IS_SUBDOMAIN')
rspamd_config:register_dependency('BAD_TLD_AND_SUBDOMAIN', 'BAD_TLD')
rspamd_config:register_dependency('51_OR_MORE_RECIPIENTS', '11_OR_MORE_RECIPIENTS')
rspamd_config:register_dependency('101_OR_MORE_RECIPIENTS', '51_OR_MORE_RECIPIENTS')
rspamd_config:register_dependency('151_OR_MORE_RECIPIENTS', '101_OR_MORE_RECIPIENTS')
rspamd_config:register_dependency('201_OR_MORE_RECIPIENTS', '151_OR_MORE_RECIPIENTS')
