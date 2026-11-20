'use client';

import React from 'react';

export interface AvatarItem {
  imageUrl: string;
  profileUrl: string;
}

export interface AvatarCirclesProps {
  numPeople?: number;
  avatarUrls: AvatarItem[];
  className?: string;
}

export const AvatarCircles: React.FC<AvatarCirclesProps> = ({
  numPeople,
  avatarUrls,
  className = '',
}) => {
  return (
    <div className={`avatar-circles-wrap ${className}`}>
      {avatarUrls.map((item, idx) => (
        <a
          key={`${item.profileUrl}-${idx}`}
          href={item.profileUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="avatar-circle-link"
          title={item.profileUrl.replace('https://github.com/', '@')}
        >
          <img
            src={item.imageUrl}
            alt="Collaborator avatar"
            width={34}
            height={34}
            className="avatar-circle-img"
            loading="lazy"
          />
        </a>
      ))}
      {typeof numPeople === 'number' && numPeople > 0 ? (
        <span className="avatar-circle-count">+{numPeople}</span>
      ) : null}
    </div>
  );
};

export default AvatarCircles;
