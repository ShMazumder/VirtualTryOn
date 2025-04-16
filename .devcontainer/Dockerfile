FROM dart

RUN groupadd -g 1000 vscode && \
    useradd -m -s /bin/bash -u 1000 -g vscode vscode

RUN apt-get update
RUN apt-get install sudo
RUN apt-get install -y curl git unzip xz-utils zip libglu1-mesa

RUN apt-get clean

RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /flutter
ENV PATH="/flutter/bin:$PATH"
RUN flutter doctor

RUN npm install -g firebase-tools
