#!/bin/bash
set -e
set -o pipefail
export LC_ALL=C.UTF-8
export TZ=Africa/Algiers

# Verify required environment variables
if [ -z "$CHANNEL_ID" ] || [ -z "$YOUTUBE_API_KEY" ]; then
    echo "Error: CHANNEL_ID and YOUTUBE_API_KEY environment variables must be set"
    exit 1
fi

mkdir -p /tmp/live

# === الترقيع تاع Render Web Service المجاني ===
echo "نشعلو سيرفر وهمي على Port $PORT باه Render ما يقتلش البث"
python3 -m http.server "${PORT:-10000}" &

FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FONT_EMOJI="/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf"
START_TIME=$(date +%s)
echo "$START_TIME" > /tmp/live/start_time.txt

echo "نجبدو الاسم واللوجو من يوتيوب..."
API_STATIC=$(curl -s --fail --max-time 10 "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=${CHANNEL_ID}&key=${YOUTUBE_API_KEY}" 2>/dev/null || echo "")
if [ -n "$API_STATIC" ] && [ "$(echo "$API_STATIC" | jq -r '.items | length' 2>/dev/null)" -gt 0 ]; then
    LOGO_URL=$(echo "$API_STATIC" | jq -r '.items[0].snippet.thumbnails.high.url' 2>/dev/null)
    if [ -n "$LOGO_URL" ] && [ "$LOGO_URL" != "null" ]; then
        curl -s --fail --max-time 10 "$LOGO_URL" -o /tmp/live/logo.png 2>/dev/null || touch /tmp/live/logo.png
        echo "تم جلب اللوجو"
    else
        cp logo.png /tmp/live/logo.png 2>/dev/null || touch /tmp/live/logo.png
    fi
else
    cp logo.png /tmp/live/logo.png 2>/dev/null || touch /tmp/live/logo.png
fi

echo "ɪʈʂ ʈɑkɪ!! 🇩🇿²⁴" > /tmp/live/channel_name.txt

update_data() {
    NEWS=(
        "عاجل: مواطن لقى 50 دج في سروال قديم، راه يخمم يشري بيها قناة يوتيوب"
        "دراسة: 90% من الجزائريين يديرو لايك قبل ما يتفرجو في الفيديو"
        "واحد شرا تلفون جديد باه يتصور سيلفي مع الكسكسي"
        "خبير اقتصادي: سعر اللايك رايح يطلع في 2027"
        "طفل صغير سقسا باباه: علاش ما عندناش واي فاي في الكرش؟"
        "عاجل: انقطاع الانترنت لمدة دقيقة سبب ازمة نفسية جماعية"
        "مواطن دار حادث مرور بسب انو كان يخمم في كابشن ستوري"
        "وزارة التعليم: نفكرو ندخلو مادة 'كيفاش ترد على الكومنت' في الباك"
        "عاجل: واحد ربح في لعبة الحبار في البلايستيشن وحس روحو ناجح"
        "دراسة جديدة: الشارجور هو اكثر حاجة تتسرق في الدار"
        "مواطن طلب من الذكاء الاصطناعي يكتبله تعبير، جاه فيه 'دير لايك'"
        "عاجل: قط هرب من الدار كي سمع مولاه يغني في البث"
        "واحد بدل اسم ولدو لـ 'subscribe' باه يجيب مشتركين"
        "خبير تغذية: الكسكسي باللايكات يزيد في الطاقة"
        "عاجل: بطارية تلفون طاحت لـ 1%، الشعب في حالة طوارئ"
        "مواطن دار عرس ونسى يعرض الانترنت، العرس فشل"
        "دراسة: اللي ما يديرش كومنت في النهار تجيه الكوابيس"
        "واحد حلم انو عندو مليون مشترك، ناض لقى روحو بالغ في النوم"
        "عاجل: الجارة طلقت راجلها على جال ما دارلهاش قلب في الستوري"
        "خبير: الضحك في التعليقات يحرق سعرات حرارية اكثر من الجري"
        "مواطن باع الكبش تاع العيد باه يشري مايك للبث"
        "عاجل: داندو جديد يخليك تطير اذا درت لايك 3 مرات"
        "واحد دخل للجامع بالكاسك باه يسمع البث المباشر"
        "دراسة: 99% من المشاكل تتحل اذا طفيت الراوتر وشعلتو"
        "عاجل: اختراع تطبيق يبدل 'راني جاي' الى 'راني وصلت'"
        "مواطن شرا نظارات شمسية باه ما يشوفوش الدموع كي ينقصو المشتركين"
        "خبير: اللي يتفرج بث 24/7 يولي يفهم لغة القطوط"
        "عاجل: واحد تزوج سيري باه تجاوبو كي يقول 'صباح الخير'"
        "مواطن دار رجيم، نقص 10 كيلو من الصبر برك"
        "دراسة: اكثر كلمة يقولها الجزائري هي 'واين ندير لايك؟'"
        "عاجل: اختراع كرسي يهزك وحدو كي يجي اشعار جديد"
        "واحد راح للطبيب قالو: قلبي يخبط كي نشوف زر الاشتراك احمر"
        "خبير اقتصادي: قيمة 'تم' وصلت لمليون سنتيم في السوق السوداء"
        "عاجل: مطر صبت، الشعب كامل خرج يصور الستوري"
        "مواطن حط الكاميرا في الثلاجة باه يصور 'محتوى بارد'"
        "دراسة: اللي ما عندوش انترنت يحس روحو في العصر الحجري"
        "عاجل: واحد قرا التعليقات تاعو كلها، دخل موسوعة غينيس"
        "مواطن بدل كلمة السر تاعو لـ 'لايك_اشتراك_كومنت'"
        "خبير: النوم 8 سوايع خرافة، الصح تنوض تشوف الاشعارات"
        "عاجل: دجاجة باضت بيضة على شكل زر لايك"
        "واحد دار كورتاج بالراوتر في الحومة نهار جاهم الفيبر"
        "دراسة: الضحك على النكت البايخة يطول العمر 10 سنين"
        "عاجل: استاذ طرد تلميذ على جال ما دارلوش متابعة"
        "مواطن حاول يفليكسي باللايكات، صاحب الحانوت بلع عليه"
        "خبير: اسرع طريقة باش ترقد هي تتفرج بث تعليمي"
        "عاجل: واحد لقى كنز، فيه 1000 لايك ذهبي"
        "مواطن شرا خروف وسماه 'مشترك' باه يذبحو في العيد"
        "دراسة: اللي يدير قلب ازرق عندو مشاكل عاطفية"
        "عاجل: الشمس غابت، الشعب قال 'كون غير تطلع في البث'"
        "واحد كتب في السيفي: خبرة 10 سنين في مشاهدة البثوث"
    )
    MOTIV=(
        "ما تستناش الوقت المناسب، دير لايك ضرك"
        "النجاح يبدا بضغطة على زر الاشتراك"
        "اليوم تعب، غدوة تفرح بالمشتركين"
        "اذا ما درتش لايك، شكون رايح يدير؟"
        "كل لايك يقربك لهدفك بخطوة"
        "ما تخليش الحلم تاعك في المسودة"
        "المتابعين ما يجوش وحدوهم، جيبهم بكومنت"
        "كونك انت البث اللي تحب تشوفو"
        "ما تقارنش بدايتك بنهاية غيرك"
        "اضرب والمشتركين يجو، ما تسناش المعجزة"
        "اللايك في وقتو خير من الف في الارشيف"
        "دير محتوى حتى لو شافوه 3 عباد"
        "الاستمرارية هي اللي تصنع الفرق"
        "حلمك يستاهل 24/7 خدمة"
        "ما تقولش منقدرش، قول نجرب"
        "كل يوم فرصة جديدة للمشتركين"
        "اللي يضحك اخيرا هو اللي ما حبسش البث"
        "خلي الكومنت تاعك يهدر عليك"
        "ما تخافش من الصفر، كل واحد بدا منو"
        "الاشتراك مجاني، بصح يغير حياتك"
        "اذا طحت نوض، واذا حبس البث عاودو"
        "ما تستناش التشجيع، شجع روحك"
        "دير اللي عليك وخلي المشتركين على ربي"
        "البث تاعك، القوانين تاوعك"
        "كل فيديو درس، وكل لايك شهادة"
        "ما تبيعش حلمك على جال تعليق سلبي"
        "النجاح صوتو عالي، خليه يسمعوه"
        "كون انت التريند، ما تبعوش"
        "ما تضيعش وقتك، ضيع وقت غيرك بالضحك"
        "الحياة قصيرة، البث طويل"
        "دير كومنت كي شغل راك تهدر مع صحابك"
        "اذا ما عجبهمش المحتوى، بدل الجمهور"
        "الاحلام ما عندهاش تاريخ صلاحية"
        "اشترك اليوم باه تضحك غدوة"
        "ما تخليش زر اللايك يصدي"
        "الفرق بينك وبين الناجح: هو ما حبسش"
        "كل اشعار جديد هو تصفيقة ليك"
        "اخدم في الصمت، خلي المشتركين يديرو الضجة"
        "ما تقولش صعيب، قول جديد عليا"
        "البث هذا راهو يخدم عليك وانت راقد"
        "اللايك تاعك ممكن يبدل نهار واحد"
        "ما تستناش الكمال، ابدا بالموجود"
        "كون السبب باش واحد يضحك اليوم"
        "الطريق طويل، بصح اللايكات تقصرو"
        "ما تندمش على بث درتو، اندم على اللي ما درتوش"
        "خلي شغفك يبان في كل فريم"
        "النجاح هو انك تزيد تكمل كي الناس تحبس"
        "دير متابعة، راك تربح صاحب"
        "الحلم الكبير يبدا بلايك صغير"
        "ما تحبسش حتى يولي اسمك يرن"
    )
    RIDDLES=(
        "ما هو الشيء الذي كلما زاد نقص؟ | العمر"
        "شيء يمشي بلا رجلين ويبكي بلا عينين؟ | السحاب"
        "ما هو الشيء الذي له اسنان ولا يعض؟ | المشط"
        "شيء تاكلو بصح ما تاكلوش؟ | الصحن"
        "ما هو البيت الذي ليس فيه ابواب ولا نوافذ؟ | بيت الشعر"
        "شيء اذا لمستو يصرخ؟ | الجرس"
        "ما هو الشيء الذي في السماء اذا زدت له حرف صار في الارض؟ | نجم - منجم"
        "شيء له اربع ارجل ولا يمشي؟ | الكرسي"
        "ما هو الشيء الذي نصفه ناشف ونصفه مبلول؟ | السفينة"
        "شيء كلما اخذت منو كبر؟ | الحفرة"
        "ما هو الشيء الذي يقرصك ولا تراه؟ | الجوع"
        "شيء موجود في الدقيقة مرتين وفي القرن مرة؟ | حرف القاف"
        "ما هو الشيء الذي يمشي ويقف وليس له ارجل؟ | الساعة"
        "شيء له عين ولا يرى؟ | الابرة"
        "ما هو الشيء الذي اذا غليته جمد؟ | البيض"
        "شيء تشوفو في الليل 3 مرات وفي النهار مرة؟ | حرف اللام"
        "ما هو الشيء الذي يكتب ولا يقرأ؟ | القلم"
        "شيء اذا حذفت اوله صار عظيم الشان؟ | درب"
        "ما هو الشيء الذي له رقبة بلا راس؟ | القارورة"
        "شيء يطلع شجرة بلا روح؟ | الورق"
        "ما هو الشيء الذي اسمو على لونو؟ | البيضة"
        "شيء يكسو الناس وهو عاري؟ | الابرة"
        "ما هو الشيء الذي يتكلم جميع لغات العالم؟ | الصدى"
        "شيء في جسمك من 3 حروف الاول والثاني طائر؟ | بطن"
        "ما هو الشيء الذي قلبه ياكل قشرو؟ | الشمعة"
        "شيء يطير بلا جناحين ويبكي بلا عينين؟ | السحاب"
        "ما هو الشيء الذي يخترق الزجاج ولا يكسره؟ | الضوء"
        "شيء اذا دخل الماء ضاع وتشتت؟ | السكر"
        "ما هو الشيء الذي لا يمشي الا بالضرب؟ | المسمار"
        "شيء موجود في كل بيت؟ | حرف الياء"
        "ما هو الشيء الذي يشيلك وتشيلو؟ | الحذاء"
        "شيء له اوراق وليس له جذور؟ | الكتاب"
        "ما هو الشيء الذي كلما كثر غلا وكلما قل رخص؟ | العقل"
        "شيء يتحرك حولك دائما ولا تراه؟ | الهواء"
        "ما هو الشيء الذي يلبس قبعته في النهار ويخلعها في الليل؟ | القلم"
        "شيء يولد في الشهر مرة؟ | الهلال"
        "ما هو الشيء الذي يسمع بلا اذن ويتكلم بلا لسان؟ | الهاتف"
        "شيء اذا شرب مات واذا اكل عاش؟ | النار"
        "ما هو الشيء الذي له خمسة اصابع بلا لحم ولا عظم؟ | القفاز"
        "شيء يجري بلا ارجل؟ | النهر"
        "ما هو الشيء الذي تحمله ويحملك؟ | الحذاء"
        "شيء ابيض كالثلج اسود من الليل؟ | الكحل"
        "ما هو الشيء الذي ينام ولا يقوم؟ | الرماد"
        "شيء اذا كثرت استعماله صار جديد؟ | العقل"
        "ما هو الشيء الذي يذهب ولا يرجع؟ | الدخان"
        "شيء يبل الارض ولا يبللها؟ | الظل"
        "ما هو الشيء الذي له راس ولا عين له؟ | الدبوس"
        "شيء ياكل ولا يشبع؟ | النار"
        "ما هو الشيء الذي لا تحب ان تلبسه واذا لبسته لا تراه؟ | الكفن"
        "شيء يرفع اثقال ولا يقدر يرفع مسمار؟ | البحر"
    )
    ADHKAR=(
        "سبحان الله وبحمده"
        "لا إله إلا الله وحده لا شريك له"
        "استغفر الله العظيم"
        "اللهم صل على محمد"
        "لا حول ولا قوة إلا بالله"
    )

    LAST_STATS_FETCH=0
    RIDDLE_START_TIME=0
    RIDDLE_INDEX=0
    LAST_SUBS=0
    echo "0" > /tmp/live/subs_today.txt
    echo "" > /tmp/live/dhikr.txt

    while true; do
        CURRENT_TIME=$(date +%s)

        # 1. احصائيات القناة كل دقيقة
        if [ $((CURRENT_TIME - LAST_STATS_FETCH)) -ge 60 ]; then
            API_STATS=$(curl -s --fail --max-time 10 "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=${CHANNEL_ID}&key=${YOUTUBE_API_KEY}" 2>/dev/null || echo "")
            if [ -n "$API_STATS" ] && [ "$(echo "$API_STATS" | jq -r '.items | length' 2>/dev/null)" -gt 0 ]; then
                SUBS=$(echo "$API_STATS" | jq -r '.items[0].statistics.subscriberCount // "0"' 2>/dev/null)
                echo "$SUBS" > /tmp/live/subs.txt
                echo "$API_STATS" | jq -r '.items[0].statistics.viewCount // "0"' 2>/dev/null > /tmp/live/views.txt

                [ "$LAST_SUBS" -eq 0 ] && LAST_SUBS="$SUBS"
                SUBS_TODAY=$((SUBS - LAST_SUBS))
                [ "$SUBS_TODAY" -lt 0 ] && SUBS_TODAY=0
                echo "🔥 اليوم: +$SUBS_TODAY" > /tmp/live/subs_today.txt

                HOUR_DZ=$(TZ=Africa/Algiers date +%H)
                MIN_DZ=$(TZ=Africa/Algiers date +%M)
                if [ "$HOUR_DZ" = "00" ] && [ "$MIN_DZ" = "00" ]; then
                    LAST_SUBS="$SUBS"
                fi

                LAST_STATS_FETCH=$CURRENT_TIME
            fi
        fi

        # 2. المشاهدين واللايكات
        if [ -n "${LIVE_VIDEO_ID}" ]; then
            LIVE_STATS=$(curl -s --fail --max-time 10 "https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails,statistics&id=${LIVE_VIDEO_ID}&key=${YOUTUBE_API_KEY}" 2>/dev/null || echo "")
            VIEWERS=$(echo "$LIVE_STATS" | jq -r '.items[0].liveStreamingDetails.concurrentViewers // "0"' 2>/dev/null)
            LIKES=$(echo "$LIVE_STATS" | jq -r '.items[0].statistics.likeCount // "0"' 2>/dev/null)
            echo "👀 $VIEWERS" > /tmp/live/viewers.txt
            echo "👍 $LIKES" > /tmp/live/likes.txt
        fi

        # Create default files if missing
        [ ! -f /tmp/live/subs.txt ] && echo "0" > /tmp/live/subs.txt
        [ ! -f /tmp/live/views.txt ] && echo "0" > /tmp/live/views.txt
        [ ! -f /tmp/live/viewers.txt ] && echo "👀 0" > /tmp/live/viewers.txt
        [ ! -f /tmp/live/likes.txt ] && echo "👍 0" > /tmp/live/likes.txt

        # 3. الوقت و Uptime
        echo "$(TZ=Africa/Algiers date +%H:%M:%S)" > /tmp/live/time.txt
        UPTIME=$(( CURRENT_TIME - START_TIME ))
        HOURS=$(( UPTIME / 3600 ))
        MINUTES=$(( (UPTIME % 3600) / 60 ))
        printf "⏰ شاعل: %02d:%02d" "$HOURS" "$MINUTES" > /tmp/live/uptime.txt

        # 4. الهدف المتحرك
        GOAL_FILE="/tmp/live/goal_value.txt"
        [ ! -f "$GOAL_FILE" ] && echo "5000" > "$GOAL_FILE"
        GOAL=$(cat "$GOAL_FILE")
        SUBS=$(cat /tmp/live/subs.txt)
        if [ "$SUBS" -ge "$GOAL" ]; then
            GOAL=$(( GOAL * 2 ))
            echo "$GOAL" > "$GOAL_FILE"
            echo "🎉 مبروك! الهدف الجديد: $GOAL" > /tmp/live/news.txt
        fi
        PERCENT=$(( SUBS * 100 / GOAL ))
        REMAIN=$(( GOAL - SUBS ))
        [ "$PERCENT" -gt 99 ] && PERCENT=99 && REMAIN=1
        echo "🎯 الهدف: $GOAL" > /tmp/live/goal.txt
        printf '█%.0s' $(seq 1 $((PERCENT/5))) > /tmp/live/bar.txt
        printf '░%.0s' $(seq 1 $((20 - PERCENT/5)))) >> /tmp/live/bar.txt
        echo "$PERCENT%" > /tmp/live/percent.txt
        echo "باقي $REMAIN" > /tmp/live/remain.txt

        # 5. الأخبار والتحفيز
        PICK=$(( (CURRENT_TIME / 60) % 50 ))
        echo "${NEWS[$PICK]}" | fold -s -w 35 > /tmp/live/news.txt
        PICK2=$(( (CURRENT_TIME / 120) % 50 ))
        echo "💪 جرعة تحفيز:" > /tmp/live/motiv1.txt
        echo "${MOTIV[$PICK2]}" > /tmp/live/motiv2.txt

        # 6. الأذكار كل ساعة
        if [ $((CURRENT_TIME % 3600)) -lt 30 ]; then
            PICK_DHIKR=$(( RANDOM % 5 ))
            echo "🕌 ${ADHKAR[$PICK_DHIKR]}" > /tmp/live/dhikr.txt
        else
            echo "" > /tmp/live/dhikr.txt
        fi

        # 7. الألغاز
        if [ $((CURRENT_TIME - RIDDLE_START_TIME)) -ge 180 ]; then
            RIDDLE_INDEX=$(( RANDOM % 50 ))
            RIDDLE_START_TIME=$CURRENT_TIME
        fi
        FULL_RIDDLE="${RIDDLES[$RIDDLE_INDEX]}"
        TIME_PASSED=$((CURRENT_TIME - RIDDLE_START_TIME))
        if [ "$TIME_PASSED" -lt 120 ]; then
            QUESTION_ONLY=$(echo "$FULL_RIDDLE" | cut -d'|' -f1)
            TIME_LEFT=$((120 - TIME_PASSED))
            echo "🧠 لغز: $QUESTION_ONLY | ⏰ $TIME_LEFT ثا" > /tmp/live/riddle.txt
        else
            echo "🧠 لغز: $FULL_RIDDLE | ✅" > /tmp/live/riddle.txt
        fi

        sleep 15
    done
}

update_data &
DATA_PID=$!

# Trap to handle errors and cleanup
trap 'echo "⚠️ ffmpeg طاح $(TZ=Africa/Algiers date)" >> /tmp/live/logs.txt && kill $DATA_PID 2>/dev/null; sleep 10' ERR

CHANNEL_NAME=$(cat /tmp/live/channel_name.txt 2>/dev/null || echo "Unknown")

while true; do
    ffmpeg -hide_banner -loglevel warning \
    -re -stream_loop -1 -i video.mp4 \
    -loop 1 -i /tmp/live/logo.png \
    -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
    -filter_complex "[0:v]scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,setsar=1,boxblur=5:1[bg]; \
    [bg][1:v]overlay=main_w-overlay_w-40:40[ol]; \
    [ol]drawbox=x=0:y=0:w=1280:h=60:color=#6a0dad@0.95:t=fill[topbar]; \
    [topbar]drawtext=fontfile=$FONT_EMOJI:text='🟢':fontsize=36:x=40:y=12[green]; \
    [green]drawtext=fontfile=$FONT:text=' live بث ':fontcolor=white:fontsize=36:x=85:y=12[live1]; \
    [live1]drawtext=fontfile=$FONT:text='$CHANNEL_NAME':fontcolor=white:fontsize=36:x=280:y=12[name]; \
    [name]drawtext=fontfile=$FONT:text=' الرسمي 24/7':fontcolor=white:fontsize=36:x=620:y=12; \
    drawtext=fontfile=$FONT:textfile=/tmp/live/time.txt:reload=1:fontcolor=white:fontsize=36:x=w-text_w-40:y=12; \
    drawtext=fontfile=$FONT:textfile=/tmp/live/uptime.txt:reload=1:fontcolor=#aaaaaa:fontsize=24:x=w-text_w-40:y=40[header]; \
    [header]drawbox=x=0:y=60:w=640:h=600:color=#1a1a1a@0.85:t=fill[leftbox]; \
    [leftbox]drawtext=fontfile=$FONT_EMOJI:text='📊':fontsize=32:x=40:y=80[chart]; \
    [chart]drawtext=fontfile=$FONT:text=' احصائيات القناة':fontcolor=#00ffff:fontsize=32:x=85:y=80[st]; \
    [st]drawtext=fontfile=$FONT:text='$CHANNEL_NAME':fontcolor=white:fontsize=48:x=(640-text_w)/2:y=140[name2]; \
    [name2]drawtext=fontfile=$FONT:text='المشتركين':fontcolor=#aaaaaa:fontsize=28:x=(640-text_w)/2:y=220[subtxt]; \
    [subtxt]drawtext=fontfile=$FONT:textfile=/tmp/live/subs.txt:reload=1:fontcolor=#00ff00:fontsize=60:x=(640-text_w)/2:y=260; \
    drawtext=fontfile=$FONT:textfile=/tmp/live/subs_today.txt:reload=1:fontcolor=#ff9900:fontsize=28:x=(640-text_w)/2:y=330[today]; \
    [today]drawbox=x=40:y=380:w=560:h=2:color=white@0.3:t=fill; \
    drawtext=fontfile=$FONT:textfile=/tmp/live/goal.txt:reload=1:fontcolor=yellow:fontsize=30:x=40:y=400[goal]; \
    [goal]drawtext=fontfile=$FONT:textfile=/tmp/live/bar.txt:reload=1:fontcolor=#00ff00:fontsize=28:x=40:y=440:line_spacing=0; \
    drawtext=fontfile=$FONT:textfile=/tmp/live/percent.txt:reload=1:fontcolor=white:fontsize=32:x=520:y=435; \
    drawtext=fontfile=$FONT:textfile=/tmp/live/remain.txt:reload=1:fontcolor=#ff9900:fontsize=24:x=40:y=480[rem]; \
    [rem]drawtext=fontfile=$FONT_EMOJI:text='👁️':fontsize=28:x=40:y=520[eye]; \
    [eye]drawtext=fontfile=$FONT:textfile=/tmp/live/views.txt:reload=1:fontcolor=white:fontsize=32:x=80:y=518[views]; \
    [views]drawtext=fontfile=$FONT:textfile=/tmp/live/viewers.txt:reload=1:fontcolor=#00ffff:fontsize=28:x=300:y=520; \
    drawtext=fontfile=$FONT:textfile=/tmp/live/likes.txt:reload=1:fontcolor=#ff66ff:fontsize=28:x=450:y=520[stats]; \
    [stats]drawbox=x=640:y=60:w=640:h=600:color=#0d0d0d@0.85:t=fill[rightbox]; \
    [rightbox]drawtext=fontfile=$FONT_EMOJI:text='📰':fontsize=32:x=680:y=80; \
    drawtext=fontfile=$FONT:text=' اخبار dz المضحكة':fontcolor=#ff6600:fontsize=32:x=725:y=80[nt]; \
    [nt]drawbox=x=660:y=130:w=600:h=180:color=#2a2a2a@0.9:t=fill[newsbg]; \
    [newsbg]drawtext=fontfile=$FONT:textfile=/tmp/live/news.txt:reload=1:fontcolor=white:fontsize=26:x=680:y=145:line_spacing=8[newstxt]; \
    [newstxt]drawtext=fontfile=$FONT:textfile=/tmp/live/motiv1.txt:reload=1:fontcolor=#ff00ff:fontsize=30:x=680:y=330[m1]; \
    [m1]drawtext=fontfile=$FONT:textfile=/tmp/live/motiv2.txt:reload=1:fontcolor=white:fontsize=26:x=680:y=370:w=580:fix_bounds=1[m2]; \
    [m2]drawtext=fontfile=$FONT:textfile=/tmp/live/dhikr.txt:reload=1:fontcolor=#00ff00:fontsize=28:x=680:y=450:alpha='if(gt(st(0\,t)\,0),1,0)'[dhikr]; \
    [dhikr]drawtext=fontfile=$FONT:text='دير لايك 😂 | كومنت 🔥 | اشتراك ❤️':fontcolor=#00ffff:fontsize=28:x=680:y=500[cta]; \
    [cta]drawbox=x=0:y=660:w=1280:h=60:color=#6a0dad@0.95:t=fill[botbar]; \
    [botbar]drawtext=fontfile=$FONT:textfile=/tmp/live/riddle.txt:reload=1:fontcolor=white:fontsize=24:x=40:y=678:w=1200:fix_bounds=1[vo]; \
    [2:a]volume=0.0[ao]" \
    -map "[vo]" -map "[ao]" \
    -c:v libx264 -preset ultrafast -tune zerolatency -threads 1 \
    -pix_fmt yuv420p \
    -b:v 1500k -maxrate 1500k -bufsize 3000k \
    -r 30 -g 60 -keyint_min 60 -sc_threshold 0 \
    -fflags +genpts+igndts -use_wallclock_as_timestamps 1 -flags low_delay \
    -c:a aac -b:a 96k -ar 44100 \
    -f flv "rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_STREAM_KEY}" || true

    sleep 10
done
