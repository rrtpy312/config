#!/bin/bash
chafa --size="$2x$3" "$1" 2>/dev/null || echo "Image preview failed"
