<?php
        $str     = 'そろそろ休みたいです。';
        $options = array('-d', '/usr/local/lib/mecab/dic/mecab-ipadic-neologd');
        $mecab = new \MeCab\Tagger($options);
        $nodes = $mecab->parseToNode($str);
        echo $str . "\n";
        foreach ($nodes as $n) {
            $stat = $n->getStat();
            // 単語かどうか
            if ($stat != 0) {
                continue;
            }
            $features = explode(',', $n->getFeature());
            if ($features[0] !== '名詞') {
                continue;
            }
            // 単語
            echo "Surface: " . $n->getSurface() . "\n";
        }