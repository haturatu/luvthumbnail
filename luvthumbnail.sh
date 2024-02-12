 #!/bin/bash

# それぞれのディレクトリパス
input_dir="/media/ncp/yt/music"
output_dir="/media/ncp/yt/musicmp3"

# 出力ディレクトリが存在しない場合は作成する
mkdir -p $output_dir

# フォーマット指定、現状出力はmp3のみ
in="webm"
out="mp3"

# ディレクトリ内全てに適応させる
#find "$input_dir" -type f -name "*$in" | while IFS= read -r file; do
shopt -s globstar
for file in "$input_dir"/**/*.${in}; do
    # baseを指定
    base=$(basename "$file" .${in})
    
    # ファイルのディレクトリ取得
    file_dir=$(dirname "$file")
    # ディレクトリパスの一部を置換して新しいパスを作成
    outfile_dir="${output_dir}${file_dir#$input_dir}"
    mkdir -p "$outfile_dir"
        
    # サムネイルのパス指定
    thumbnail="${outfile_dir}/${base}_thumbnail.jpg"
    
    # ビデオファイルからmp3に変換
    ffmpeg -i "$file" -vn -acodec libmp3lame -qscale:a 2 "$outfile_dir/${base}.${out}"
    
    # 映像ファイルからサムネイル抽出
    if ffmpeg -i "$file" -an -vframes 1 -q:v 2 "$thumbnail" -y; then
        echo "Thumbnail extracted for $base"
        
        ffmpeg -i "$outfile_dir/${base}.${out}" -i "$thumbnail" -map 0 -map 1 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" -y "$outfile_dir/${base}_with_thumbnail.${out}"
        rm "${outfile_dir}/${base}}"
        rm "${outfile_dir}/${base}_thumbnail.jpg"
        mv "${outfile_dir}/${base}_with_thumbnail.${out}" "$outfile_dir/${base}.${out}"
    else
        echo "No thumbnail found for $base"
    fi
done
